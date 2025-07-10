import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

import '/auth/custom_auth/custom_auth_user_provider.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  PatientEnrollmentProgramAuthUser? initialUser;
  PatientEnrollmentProgramAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(PatientEnrollmentProgramAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) =>
          appStateNotifier.loggedIn ? ViewGroupsWidget() : LoginWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) =>
              appStateNotifier.loggedIn ? ViewGroupsWidget() : LoginWidget(),
          routes: [
            FFRoute(
              name: PESPatientListWidget.routeName,
              path: PESPatientListWidget.routePath,
              builder: (context, params) => PESPatientListWidget(),
            ),
            FFRoute(
              name: ReloadPageWidget.routeName,
              path: ReloadPageWidget.routePath,
              builder: (context, params) => ReloadPageWidget(
                csReload: params.getParam(
                  'csReload',
                  ParamType.bool,
                ),
                patientClinicDataID: params.getParam(
                  'patientClinicDataID',
                  ParamType.int,
                ),
                clinicID: params.getParam(
                  'clinicID',
                  ParamType.int,
                ),
                pesReload: params.getParam(
                  'pesReload',
                  ParamType.bool,
                ),
                groupListReload: params.getParam(
                  'groupListReload',
                  ParamType.bool,
                ),
                globalReload: params.getParam(
                  'globalReload',
                  ParamType.bool,
                ),
                appointmentReload: params.getParam(
                  'appointmentReload',
                  ParamType.bool,
                ),
                csList: params.getParam(
                  'csList',
                  ParamType.bool,
                ),
                vpeDeferredReload: params.getParam(
                  'vpeDeferredReload',
                  ParamType.bool,
                ),
                vpeReload: params.getParam(
                  'vpeReload',
                  ParamType.bool,
                ),
                csAdminReload: params.getParam(
                  'csAdminReload',
                  ParamType.bool,
                ),
                csScreenType: params.getParam<CSScreenType>(
                  'csScreenType',
                  ParamType.Enum,
                ),
                pesScreenType: params.getParam<PESScreenType>(
                  'pesScreenType',
                  ParamType.Enum,
                ),
              ),
            ),
            FFRoute(
              name: EditGroupWidget.routeName,
              path: EditGroupWidget.routePath,
              builder: (context, params) => EditGroupWidget(
                groupId: params.getParam(
                  'groupId',
                  ParamType.int,
                ),
              ),
            ),
            FFRoute(
              name: CSAdminTransferPatientListWidget.routeName,
              path: CSAdminTransferPatientListWidget.routePath,
              builder: (context, params) => CSAdminTransferPatientListWidget(),
            ),
            FFRoute(
              name: CreateNewGroupByEMRWidget.routeName,
              path: CreateNewGroupByEMRWidget.routePath,
              builder: (context, params) => CreateNewGroupByEMRWidget(),
            ),
            FFRoute(
              name: CSAdminPatientDetailWidget.routeName,
              path: CSAdminPatientDetailWidget.routePath,
              builder: (context, params) => CSAdminPatientDetailWidget(
                patientClinicDataID: params.getParam(
                  'patientClinicDataID',
                  ParamType.int,
                ),
                clinicID: params.getParam(
                  'clinicID',
                  ParamType.int,
                ),
              ),
            ),
            FFRoute(
              name: CSFollowUpPatientListWidget.routeName,
              path: CSFollowUpPatientListWidget.routePath,
              builder: (context, params) => CSFollowUpPatientListWidget(),
            ),
            FFRoute(
              name: DuplicateGroupWidget.routeName,
              path: DuplicateGroupWidget.routePath,
              builder: (context, params) => DuplicateGroupWidget(
                groupID: params.getParam(
                  'groupID',
                  ParamType.int,
                ),
                clinicID: params.getParam(
                  'clinicID',
                  ParamType.int,
                ),
              ),
            ),
            FFRoute(
              name: CreateNewGroupIIWidget.routeName,
              path: CreateNewGroupIIWidget.routePath,
              builder: (context, params) => CreateNewGroupIIWidget(),
            ),
            FFRoute(
              name: CSTransferPatientListWidget.routeName,
              path: CSTransferPatientListWidget.routePath,
              builder: (context, params) => CSTransferPatientListWidget(),
            ),
            FFRoute(
              name: ManageClinicTimeSlotsWidget.routeName,
              path: ManageClinicTimeSlotsWidget.routePath,
              builder: (context, params) => ManageClinicTimeSlotsWidget(),
            ),
            FFRoute(
              name: PESDeferredPatientListWidget.routeName,
              path: PESDeferredPatientListWidget.routePath,
              builder: (context, params) => PESDeferredPatientListWidget(),
            ),
            FFRoute(
              name: GSListViewWidget.routeName,
              path: GSListViewWidget.routePath,
              builder: (context, params) => GSListViewWidget(),
            ),
            FFRoute(
              name: ViewVPEWidget.routeName,
              path: ViewVPEWidget.routePath,
              builder: (context, params) => ViewVPEWidget(),
            ),
            FFRoute(
              name: ViewGroupsWidget.routeName,
              path: ViewGroupsWidget.routePath,
              builder: (context, params) => ViewGroupsWidget(),
            ),
            FFRoute(
              name: CSDeferredPatientListWidget.routeName,
              path: CSDeferredPatientListWidget.routePath,
              builder: (context, params) => CSDeferredPatientListWidget(),
            ),
            FFRoute(
              name: ViewCSWidget.routeName,
              path: ViewCSWidget.routePath,
              builder: (context, params) => ViewCSWidget(),
            ),
            FFRoute(
              name: CSAdminPatientDetailSavedWidget.routeName,
              path: CSAdminPatientDetailSavedWidget.routePath,
              builder: (context, params) => CSAdminPatientDetailSavedWidget(
                patientClinicDataID: params.getParam(
                  'patientClinicDataID',
                  ParamType.int,
                ),
                clinicID: params.getParam(
                  'clinicID',
                  ParamType.int,
                ),
              ),
            ),
            FFRoute(
              name: CreateNewGroupWidget.routeName,
              path: CreateNewGroupWidget.routePath,
              builder: (context, params) => CreateNewGroupWidget(),
            ),
            FFRoute(
              name: DuplicateGroupCopyWidget.routeName,
              path: DuplicateGroupCopyWidget.routePath,
              builder: (context, params) => DuplicateGroupCopyWidget(
                groupID: params.getParam(
                  'groupID',
                  ParamType.int,
                ),
                clinicID: params.getParam(
                  'clinicID',
                  ParamType.int,
                ),
              ),
            ),
            FFRoute(
              name: NoPatientsWidget.routeName,
              path: NoPatientsWidget.routePath,
              builder: (context, params) => NoPatientsWidget(),
            ),
            FFRoute(
              name: CSPatientDetailSavedWidget.routeName,
              path: CSPatientDetailSavedWidget.routePath,
              builder: (context, params) => CSPatientDetailSavedWidget(
                patientClinicDataID: params.getParam(
                  'patientClinicDataID',
                  ParamType.int,
                ),
                clinicID: params.getParam(
                  'clinicID',
                  ParamType.int,
                ),
                csScreenType: params.getParam<CSScreenType>(
                  'csScreenType',
                  ParamType.Enum,
                ),
              ),
            ),
            FFRoute(
              name: GSPatientListWidget.routeName,
              path: GSPatientListWidget.routePath,
              builder: (context, params) => GSPatientListWidget(),
            ),
            FFRoute(
              name: GSPatientDetailWidget.routeName,
              path: GSPatientDetailWidget.routePath,
              builder: (context, params) => GSPatientDetailWidget(
                patientClinicDataID: params.getParam(
                  'patientClinicDataID',
                  ParamType.int,
                ),
                clinicID: params.getParam(
                  'clinicID',
                  ParamType.int,
                ),
              ),
            ),
            FFRoute(
              name: PESPatientDetailWidget.routeName,
              path: PESPatientDetailWidget.routePath,
              builder: (context, params) => PESPatientDetailWidget(
                patientClinicDataID: params.getParam(
                  'patientClinicDataID',
                  ParamType.int,
                ),
                clinicID: params.getParam(
                  'clinicID',
                  ParamType.int,
                ),
                pesScreenType: params.getParam<PESScreenType>(
                  'pesScreenType',
                  ParamType.Enum,
                ),
              ),
            ),
            FFRoute(
              name: PESPatientDetailSavedWidget.routeName,
              path: PESPatientDetailSavedWidget.routePath,
              builder: (context, params) => PESPatientDetailSavedWidget(
                patientClinicDataID: params.getParam(
                  'patientClinicDataID',
                  ParamType.int,
                ),
                clinicID: params.getParam(
                  'clinicID',
                  ParamType.int,
                ),
                pesScreenType: params.getParam<PESScreenType>(
                  'pesScreenType',
                  ParamType.Enum,
                ),
              ),
            ),
            FFRoute(
              name: ArchivedGroupsWidget.routeName,
              path: ArchivedGroupsWidget.routePath,
              builder: (context, params) => ArchivedGroupsWidget(),
            ),
            FFRoute(
              name: GSPatientViewCopyWidget.routeName,
              path: GSPatientViewCopyWidget.routePath,
              builder: (context, params) => GSPatientViewCopyWidget(
                patientClinicDataID: params.getParam(
                  'patientClinicDataID',
                  ParamType.int,
                ),
                clinicID: params.getParam(
                  'clinicID',
                  ParamType.int,
                ),
              ),
            ),
            FFRoute(
              name: ViewPESWidget.routeName,
              path: ViewPESWidget.routePath,
              builder: (context, params) => ViewPESWidget(),
            ),
            FFRoute(
              name: CSPatientListWidget.routeName,
              path: CSPatientListWidget.routePath,
              builder: (context, params) => CSPatientListWidget(),
            ),
            FFRoute(
              name: CSPatientDetailWidget.routeName,
              path: CSPatientDetailWidget.routePath,
              builder: (context, params) => CSPatientDetailWidget(
                patientClinicDataID: params.getParam(
                  'patientClinicDataID',
                  ParamType.int,
                ),
                clinicID: params.getParam(
                  'clinicID',
                  ParamType.int,
                ),
                cSScreenType: params.getParam<CSScreenType>(
                  'cSScreenType',
                  ParamType.Enum,
                ),
              ),
            ),
            FFRoute(
              name: GSPatientViewSavedWidget.routeName,
              path: GSPatientViewSavedWidget.routePath,
              builder: (context, params) => GSPatientViewSavedWidget(
                patientClinicDataID: params.getParam(
                  'patientClinicDataID',
                  ParamType.int,
                ),
                clinicID: params.getParam(
                  'clinicID',
                  ParamType.int,
                ),
              ),
            ),
            FFRoute(
              name: UpdateGroupWidget.routeName,
              path: UpdateGroupWidget.routePath,
              builder: (context, params) => UpdateGroupWidget(
                groupId: params.getParam(
                  'groupId',
                  ParamType.int,
                ),
              ),
            ),
            FFRoute(
              name: GSPatientViewWidget.routeName,
              path: GSPatientViewWidget.routePath,
              builder: (context, params) => GSPatientViewWidget(
                patientClinicDataID: params.getParam(
                  'patientClinicDataID',
                  ParamType.int,
                ),
                clinicID: params.getParam(
                  'clinicID',
                  ParamType.int,
                ),
              ),
            ),
            FFRoute(
              name: CtcWidget.routeName,
              path: CtcWidget.routePath,
              builder: (context, params) => CtcWidget(),
            ),
            FFRoute(
              name: PESFollowUpPatientListWidget.routeName,
              path: PESFollowUpPatientListWidget.routePath,
              builder: (context, params) => PESFollowUpPatientListWidget(),
            ),
            FFRoute(
              name: LoginWidget.routeName,
              path: LoginWidget.routePath,
              builder: (context, params) => LoginWidget(),
            ),
            FFRoute(
              name: VPEDashboardWidget.routeName,
              path: VPEDashboardWidget.routePath,
              builder: (context, params) => VPEDashboardWidget(),
            ),
            FFRoute(
              name: VPEDeferredPatientsWidget.routeName,
              path: VPEDeferredPatientsWidget.routePath,
              builder: (context, params) => VPEDeferredPatientsWidget(
                patientClinicDataId: params.getParam(
                  'patientClinicDataId',
                  ParamType.int,
                ),
              ),
            )
          ].map((r) => r.toRoute(appStateNotifier)).toList(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/Login';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(
        hasTransition: true,
        transitionType: PageTransitionType.fade,
        duration: Duration(milliseconds: 400),
      );
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
