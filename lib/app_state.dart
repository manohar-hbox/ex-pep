import 'package:flutter/material.dart';
import 'flutter_flow/request_manager.dart';
import '/backend/schema/structs/index.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    secureStorage = FlutterSecureStorage();
    await _safeInitAsync(() async {
      _loginToken =
          await secureStorage.getString('ff_loginToken') ?? _loginToken;
    });
    await _safeInitAsync(() async {
      _userEmailAddress =
          await secureStorage.getString('ff_userEmailAddress') ??
              _userEmailAddress;
    });
    await _safeInitAsync(() async {
      _hasuraToken =
          await secureStorage.getString('ff_hasuraToken') ?? _hasuraToken;
    });
    await _safeInitAsync(() async {
      _usertype = await secureStorage.getString('ff_usertype') ?? _usertype;
    });
    await _safeInitAsync(() async {
      _username = await secureStorage.getString('ff_username') ?? _username;
    });
    await _safeInitAsync(() async {
      _loginEmail =
          await secureStorage.getString('ff_loginEmail') ?? _loginEmail;
    });
    await _safeInitAsync(() async {
      _loginProfileID =
          await secureStorage.getString('ff_loginProfileID') ?? _loginProfileID;
    });
    await _safeInitAsync(() async {
      _vpeusertype =
          await secureStorage.getString('ff_vpeusertype') ?? _vpeusertype;
    });
    await _safeInitAsync(() async {
      _vpeadminusertype =
          await secureStorage.getString('ff_vpeadminusertype') ??
              _vpeadminusertype;
    });
    await _safeInitAsync(() async {
      _currentPatient =
          await secureStorage.getInt('ff_currentPatient') ?? _currentPatient;
    });
    await _safeInitAsync(() async {
      _currentPatientGroupID =
          await secureStorage.getInt('ff_currentPatientGroupID') ??
              _currentPatientGroupID;
    });
    await _safeInitAsync(() async {
      _viewerClinicIDS =
          (await secureStorage.getStringList('ff_viewerClinicIDS'))
                  ?.map(int.parse)
                  .toList() ??
              _viewerClinicIDS;
    });
    await _safeInitAsync(() async {
      if (await secureStorage.read(key: 'ff_ClinicAppointmentsEmptyResponse') !=
          null) {
        try {
          _ClinicAppointmentsEmptyResponse = jsonDecode(await secureStorage
                  .getString('ff_ClinicAppointmentsEmptyResponse') ??
              '');
        } catch (e) {
          print("Can't decode persisted json. Error: $e.");
        }
      }
    });
    await _safeInitAsync(() async {
      _timerState = await secureStorage.getInt('ff_timerState') ?? _timerState;
    });
    await _safeInitAsync(() async {
      _timerlogId =
          await secureStorage.getString('ff_timerlogId') ?? _timerlogId;
    });
    await _safeInitAsync(() async {
      _redirectURL =
          await secureStorage.getString('ff_redirectURL') ?? _redirectURL;
    });
    await _safeInitAsync(() async {
      _twilioVoiceToken =
          await secureStorage.getString('ff_twilioVoiceToken') ??
              _twilioVoiceToken;
    });
    await _safeInitAsync(() async {
      _twilioCTCPhoneNo =
          await secureStorage.getString('ff_twilioCTCPhoneNo') ??
              _twilioCTCPhoneNo;
    });
    await _safeInitAsync(() async {
      _isPatientCallInProgress =
          await secureStorage.getBool('ff_isPatientCallInProgress') ??
              _isPatientCallInProgress;
    });
    await _safeInitAsync(() async {
      if (await secureStorage.read(key: 'ff_twilioCallData') != null) {
        try {
          final serializedData =
              await secureStorage.getString('ff_twilioCallData') ?? '{}';
          _twilioCallData = TwilioCallDataStruct.fromSerializableMap(
              jsonDecode(serializedData));
        } catch (e) {
          print("Can't decode persisted data type. Error: $e.");
        }
      }
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late FlutterSecureStorage secureStorage;

  String _loginToken = '';
  String get loginToken => _loginToken;
  set loginToken(String value) {
    _loginToken = value;
    secureStorage.setString('ff_loginToken', value);
  }

  void deleteLoginToken() {
    secureStorage.delete(key: 'ff_loginToken');
  }

  String _userEmailAddress = '';
  String get userEmailAddress => _userEmailAddress;
  set userEmailAddress(String value) {
    _userEmailAddress = value;
    secureStorage.setString('ff_userEmailAddress', value);
  }

  void deleteUserEmailAddress() {
    secureStorage.delete(key: 'ff_userEmailAddress');
  }

  String _hasuraToken = '';
  String get hasuraToken => _hasuraToken;
  set hasuraToken(String value) {
    _hasuraToken = value;
    secureStorage.setString('ff_hasuraToken', value);
  }

  void deleteHasuraToken() {
    secureStorage.delete(key: 'ff_hasuraToken');
  }

  String _usertype = '';
  String get usertype => _usertype;
  set usertype(String value) {
    _usertype = value;
    secureStorage.setString('ff_usertype', value);
  }

  void deleteUsertype() {
    secureStorage.delete(key: 'ff_usertype');
  }

  String _username = '';
  String get username => _username;
  set username(String value) {
    _username = value;
    secureStorage.setString('ff_username', value);
  }

  void deleteUsername() {
    secureStorage.delete(key: 'ff_username');
  }

  String _loginEmail = '';
  String get loginEmail => _loginEmail;
  set loginEmail(String value) {
    _loginEmail = value;
    secureStorage.setString('ff_loginEmail', value);
  }

  void deleteLoginEmail() {
    secureStorage.delete(key: 'ff_loginEmail');
  }

  String _loginProfileID = '';
  String get loginProfileID => _loginProfileID;
  set loginProfileID(String value) {
    _loginProfileID = value;
    secureStorage.setString('ff_loginProfileID', value);
  }

  void deleteLoginProfileID() {
    secureStorage.delete(key: 'ff_loginProfileID');
  }

  String _vpeusertype = 'ES';
  String get vpeusertype => _vpeusertype;
  set vpeusertype(String value) {
    _vpeusertype = value;
    secureStorage.setString('ff_vpeusertype', value);
  }

  void deleteVpeusertype() {
    secureStorage.delete(key: 'ff_vpeusertype');
  }

  String _vpeadminusertype = 'EA';
  String get vpeadminusertype => _vpeadminusertype;
  set vpeadminusertype(String value) {
    _vpeadminusertype = value;
    secureStorage.setString('ff_vpeadminusertype', value);
  }

  void deleteVpeadminusertype() {
    secureStorage.delete(key: 'ff_vpeadminusertype');
  }

  int _pageOffset = 0;
  int get pageOffset => _pageOffset;
  set pageOffset(int value) {
    _pageOffset = value;
  }

  int _rowsPerPage = 10;
  int get rowsPerPage => _rowsPerPage;
  set rowsPerPage(int value) {
    _rowsPerPage = value;
  }

  dynamic _rowsPerPageOptions = jsonDecode('{\"rowsPerPage\":[10,25,50,100]}');
  dynamic get rowsPerPageOptions => _rowsPerPageOptions;
  set rowsPerPageOptions(dynamic value) {
    _rowsPerPageOptions = value;
  }

  List<dynamic> _filteredPatients = [];
  List<dynamic> get filteredPatients => _filteredPatients;
  set filteredPatients(List<dynamic> value) {
    _filteredPatients = value;
  }

  void addToFilteredPatients(dynamic value) {
    filteredPatients.add(value);
  }

  void removeFromFilteredPatients(dynamic value) {
    filteredPatients.remove(value);
  }

  void removeAtIndexFromFilteredPatients(int index) {
    filteredPatients.removeAt(index);
  }

  void updateFilteredPatientsAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    filteredPatients[index] = updateFn(_filteredPatients[index]);
  }

  void insertAtIndexInFilteredPatients(int index, dynamic value) {
    filteredPatients.insert(index, value);
  }

  List<int> _filteredPatientsList = [];
  List<int> get filteredPatientsList => _filteredPatientsList;
  set filteredPatientsList(List<int> value) {
    _filteredPatientsList = value;
  }

  void addToFilteredPatientsList(int value) {
    filteredPatientsList.add(value);
  }

  void removeFromFilteredPatientsList(int value) {
    filteredPatientsList.remove(value);
  }

  void removeAtIndexFromFilteredPatientsList(int index) {
    filteredPatientsList.removeAt(index);
  }

  void updateFilteredPatientsListAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    filteredPatientsList[index] = updateFn(_filteredPatientsList[index]);
  }

  void insertAtIndexInFilteredPatientsList(int index, int value) {
    filteredPatientsList.insert(index, value);
  }

  int _filteredPatientsCount = 0;
  int get filteredPatientsCount => _filteredPatientsCount;
  set filteredPatientsCount(int value) {
    _filteredPatientsCount = value;
  }

  int _currentPatient = 68565;
  int get currentPatient => _currentPatient;
  set currentPatient(int value) {
    _currentPatient = value;
    secureStorage.setInt('ff_currentPatient', value);
  }

  void deleteCurrentPatient() {
    secureStorage.delete(key: 'ff_currentPatient');
  }

  int _currentPatientGroupID = 0;
  int get currentPatientGroupID => _currentPatientGroupID;
  set currentPatientGroupID(int value) {
    _currentPatientGroupID = value;
    secureStorage.setInt('ff_currentPatientGroupID', value);
  }

  void deleteCurrentPatientGroupID() {
    secureStorage.delete(key: 'ff_currentPatientGroupID');
  }

  List<String> _numberOfAttemptsFilter = [];
  List<String> get numberOfAttemptsFilter => _numberOfAttemptsFilter;
  set numberOfAttemptsFilter(List<String> value) {
    _numberOfAttemptsFilter = value;
  }

  void addToNumberOfAttemptsFilter(String value) {
    numberOfAttemptsFilter.add(value);
  }

  void removeFromNumberOfAttemptsFilter(String value) {
    numberOfAttemptsFilter.remove(value);
  }

  void removeAtIndexFromNumberOfAttemptsFilter(int index) {
    numberOfAttemptsFilter.removeAt(index);
  }

  void updateNumberOfAttemptsFilterAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    numberOfAttemptsFilter[index] = updateFn(_numberOfAttemptsFilter[index]);
  }

  void insertAtIndexInNumberOfAttemptsFilter(int index, String value) {
    numberOfAttemptsFilter.insert(index, value);
  }

  List<String> _groupTypeFilter = [];
  List<String> get groupTypeFilter => _groupTypeFilter;
  set groupTypeFilter(List<String> value) {
    _groupTypeFilter = value;
  }

  void addToGroupTypeFilter(String value) {
    groupTypeFilter.add(value);
  }

  void removeFromGroupTypeFilter(String value) {
    groupTypeFilter.remove(value);
  }

  void removeAtIndexFromGroupTypeFilter(int index) {
    groupTypeFilter.removeAt(index);
  }

  void updateGroupTypeFilterAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    groupTypeFilter[index] = updateFn(_groupTypeFilter[index]);
  }

  void insertAtIndexInGroupTypeFilter(int index, String value) {
    groupTypeFilter.insert(index, value);
  }

  dynamic _searchNotFound =
      jsonDecode('{\"data\":{\"pep_vw_consolidated_data\":[]}}');
  dynamic get searchNotFound => _searchNotFound;
  set searchNotFound(dynamic value) {
    _searchNotFound = value;
  }

  List<int> _addedPPCIDs = [];
  List<int> get addedPPCIDs => _addedPPCIDs;
  set addedPPCIDs(List<int> value) {
    _addedPPCIDs = value;
  }

  void addToAddedPPCIDs(int value) {
    addedPPCIDs.add(value);
  }

  void removeFromAddedPPCIDs(int value) {
    addedPPCIDs.remove(value);
  }

  void removeAtIndexFromAddedPPCIDs(int index) {
    addedPPCIDs.removeAt(index);
  }

  void updateAddedPPCIDsAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    addedPPCIDs[index] = updateFn(_addedPPCIDs[index]);
  }

  void insertAtIndexInAddedPPCIDs(int index, int value) {
    addedPPCIDs.insert(index, value);
  }

  List<dynamic> _clinicIDMapping = [];
  List<dynamic> get clinicIDMapping => _clinicIDMapping;
  set clinicIDMapping(List<dynamic> value) {
    _clinicIDMapping = value;
  }

  void addToClinicIDMapping(dynamic value) {
    clinicIDMapping.add(value);
  }

  void removeFromClinicIDMapping(dynamic value) {
    clinicIDMapping.remove(value);
  }

  void removeAtIndexFromClinicIDMapping(int index) {
    clinicIDMapping.removeAt(index);
  }

  void updateClinicIDMappingAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    clinicIDMapping[index] = updateFn(_clinicIDMapping[index]);
  }

  void insertAtIndexInClinicIDMapping(int index, dynamic value) {
    clinicIDMapping.insert(index, value);
  }

  int _appointmentDateSelectFlag = 0;
  int get appointmentDateSelectFlag => _appointmentDateSelectFlag;
  set appointmentDateSelectFlag(int value) {
    _appointmentDateSelectFlag = value;
  }

  bool _isDetailsSaved = false;
  bool get isDetailsSaved => _isDetailsSaved;
  set isDetailsSaved(bool value) {
    _isDetailsSaved = value;
  }

  dynamic _noNewPatients =
      jsonDecode('{\"data\":{\"pep_vw_patient_list\":[]}}');
  dynamic get noNewPatients => _noNewPatients;
  set noNewPatients(dynamic value) {
    _noNewPatients = value;
  }

  int _searchByAssignedGroupID = 0;
  int get searchByAssignedGroupID => _searchByAssignedGroupID;
  set searchByAssignedGroupID(int value) {
    _searchByAssignedGroupID = value;
  }

  String _currentGroupName = '';
  String get currentGroupName => _currentGroupName;
  set currentGroupName(String value) {
    _currentGroupName = value;
  }

  bool _noPatientsAvailable = false;
  bool get noPatientsAvailable => _noPatientsAvailable;
  set noPatientsAvailable(bool value) {
    _noPatientsAvailable = value;
  }

  bool _isOptionsExpanded = false;
  bool get isOptionsExpanded => _isOptionsExpanded;
  set isOptionsExpanded(bool value) {
    _isOptionsExpanded = value;
  }

  int _availableClinicsCount = 0;
  int get availableClinicsCount => _availableClinicsCount;
  set availableClinicsCount(int value) {
    _availableClinicsCount = value;
  }

  List<int> _clinicidList = [];
  List<int> get clinicidList => _clinicidList;
  set clinicidList(List<int> value) {
    _clinicidList = value;
  }

  void addToClinicidList(int value) {
    clinicidList.add(value);
  }

  void removeFromClinicidList(int value) {
    clinicidList.remove(value);
  }

  void removeAtIndexFromClinicidList(int index) {
    clinicidList.removeAt(index);
  }

  void updateClinicidListAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    clinicidList[index] = updateFn(_clinicidList[index]);
  }

  void insertAtIndexInClinicidList(int index, int value) {
    clinicidList.insert(index, value);
  }

  List<String> _selectedClinicCount = [];
  List<String> get selectedClinicCount => _selectedClinicCount;
  set selectedClinicCount(List<String> value) {
    _selectedClinicCount = value;
  }

  void addToSelectedClinicCount(String value) {
    selectedClinicCount.add(value);
  }

  void removeFromSelectedClinicCount(String value) {
    selectedClinicCount.remove(value);
  }

  void removeAtIndexFromSelectedClinicCount(int index) {
    selectedClinicCount.removeAt(index);
  }

  void updateSelectedClinicCountAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    selectedClinicCount[index] = updateFn(_selectedClinicCount[index]);
  }

  void insertAtIndexInSelectedClinicCount(int index, String value) {
    selectedClinicCount.insert(index, value);
  }

  bool _isSelectOptionsVisible = false;
  bool get isSelectOptionsVisible => _isSelectOptionsVisible;
  set isSelectOptionsVisible(bool value) {
    _isSelectOptionsVisible = value;
  }

  int _debugTest = 0;
  int get debugTest => _debugTest;
  set debugTest(int value) {
    _debugTest = value;
  }

  List<int> _viewerClinicIDS = [];
  List<int> get viewerClinicIDS => _viewerClinicIDS;
  set viewerClinicIDS(List<int> value) {
    _viewerClinicIDS = value;
    secureStorage.setStringList(
        'ff_viewerClinicIDS', value.map((x) => x.toString()).toList());
  }

  void deleteViewerClinicIDS() {
    secureStorage.delete(key: 'ff_viewerClinicIDS');
  }

  void addToViewerClinicIDS(int value) {
    viewerClinicIDS.add(value);
    secureStorage.setStringList('ff_viewerClinicIDS',
        _viewerClinicIDS.map((x) => x.toString()).toList());
  }

  void removeFromViewerClinicIDS(int value) {
    viewerClinicIDS.remove(value);
    secureStorage.setStringList('ff_viewerClinicIDS',
        _viewerClinicIDS.map((x) => x.toString()).toList());
  }

  void removeAtIndexFromViewerClinicIDS(int index) {
    viewerClinicIDS.removeAt(index);
    secureStorage.setStringList('ff_viewerClinicIDS',
        _viewerClinicIDS.map((x) => x.toString()).toList());
  }

  void updateViewerClinicIDSAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    viewerClinicIDS[index] = updateFn(_viewerClinicIDS[index]);
    secureStorage.setStringList('ff_viewerClinicIDS',
        _viewerClinicIDS.map((x) => x.toString()).toList());
  }

  void insertAtIndexInViewerClinicIDS(int index, int value) {
    viewerClinicIDS.insert(index, value);
    secureStorage.setStringList('ff_viewerClinicIDS',
        _viewerClinicIDS.map((x) => x.toString()).toList());
  }

  dynamic _UpdateAvailClinics =
      jsonDecode('{\"data\":{\"pep_vw_available_clinics\":[]}}');
  dynamic get UpdateAvailClinics => _UpdateAvailClinics;
  set UpdateAvailClinics(dynamic value) {
    _UpdateAvailClinics = value;
  }

  List<int> _emptyIntList = [];
  List<int> get emptyIntList => _emptyIntList;
  set emptyIntList(List<int> value) {
    _emptyIntList = value;
  }

  void addToEmptyIntList(int value) {
    emptyIntList.add(value);
  }

  void removeFromEmptyIntList(int value) {
    emptyIntList.remove(value);
  }

  void removeAtIndexFromEmptyIntList(int index) {
    emptyIntList.removeAt(index);
  }

  void updateEmptyIntListAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    emptyIntList[index] = updateFn(_emptyIntList[index]);
  }

  void insertAtIndexInEmptyIntList(int index, int value) {
    emptyIntList.insert(index, value);
  }

  List<dynamic> _searchPatientResults = [];
  List<dynamic> get searchPatientResults => _searchPatientResults;
  set searchPatientResults(List<dynamic> value) {
    _searchPatientResults = value;
  }

  void addToSearchPatientResults(dynamic value) {
    searchPatientResults.add(value);
  }

  void removeFromSearchPatientResults(dynamic value) {
    searchPatientResults.remove(value);
  }

  void removeAtIndexFromSearchPatientResults(int index) {
    searchPatientResults.removeAt(index);
  }

  void updateSearchPatientResultsAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    searchPatientResults[index] = updateFn(_searchPatientResults[index]);
  }

  void insertAtIndexInSearchPatientResults(int index, dynamic value) {
    searchPatientResults.insert(index, value);
  }

  List<dynamic> _gsPatients = [];
  List<dynamic> get gsPatients => _gsPatients;
  set gsPatients(List<dynamic> value) {
    _gsPatients = value;
  }

  void addToGsPatients(dynamic value) {
    gsPatients.add(value);
  }

  void removeFromGsPatients(dynamic value) {
    gsPatients.remove(value);
  }

  void removeAtIndexFromGsPatients(int index) {
    gsPatients.removeAt(index);
  }

  void updateGsPatientsAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    gsPatients[index] = updateFn(_gsPatients[index]);
  }

  void insertAtIndexInGsPatients(int index, dynamic value) {
    gsPatients.insert(index, value);
  }

  dynamic _ClinicAppointmentsEmptyResponse =
      jsonDecode('{\"data\":{\"pep_vw2_clinic_appointments\":[]}}');
  dynamic get ClinicAppointmentsEmptyResponse =>
      _ClinicAppointmentsEmptyResponse;
  set ClinicAppointmentsEmptyResponse(dynamic value) {
    _ClinicAppointmentsEmptyResponse = value;
    secureStorage.setString(
        'ff_ClinicAppointmentsEmptyResponse', jsonEncode(value));
  }

  void deleteClinicAppointmentsEmptyResponse() {
    secureStorage.delete(key: 'ff_ClinicAppointmentsEmptyResponse');
  }

  List<dynamic> _usernames = [];
  List<dynamic> get usernames => _usernames;
  set usernames(List<dynamic> value) {
    _usernames = value;
  }

  void addToUsernames(dynamic value) {
    usernames.add(value);
  }

  void removeFromUsernames(dynamic value) {
    usernames.remove(value);
  }

  void removeAtIndexFromUsernames(int index) {
    usernames.removeAt(index);
  }

  void updateUsernamesAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    usernames[index] = updateFn(_usernames[index]);
  }

  void insertAtIndexInUsernames(int index, dynamic value) {
    usernames.insert(index, value);
  }

  bool _showComment = false;
  bool get showComment => _showComment;
  set showComment(bool value) {
    _showComment = value;
  }

  int _timerState = 0;
  int get timerState => _timerState;
  set timerState(int value) {
    _timerState = value;
    secureStorage.setInt('ff_timerState', value);
  }

  void deleteTimerState() {
    secureStorage.delete(key: 'ff_timerState');
  }

  int _idleState = 0;
  int get idleState => _idleState;
  set idleState(int value) {
    _idleState = value;
  }

  bool _isPaused = false;
  bool get isPaused => _isPaused;
  set isPaused(bool value) {
    _isPaused = value;
  }

  bool _isAppMinimized = false;
  bool get isAppMinimized => _isAppMinimized;
  set isAppMinimized(bool value) {
    _isAppMinimized = value;
  }

  String _timerlogId = '';
  String get timerlogId => _timerlogId;
  set timerlogId(String value) {
    _timerlogId = value;
    secureStorage.setString('ff_timerlogId', value);
  }

  void deleteTimerlogId() {
    secureStorage.delete(key: 'ff_timerlogId');
  }

  int _csTableRowCount = 10;
  int get csTableRowCount => _csTableRowCount;
  set csTableRowCount(int value) {
    _csTableRowCount = value;
  }

  int _csTableRowIndex = 0;
  int get csTableRowIndex => _csTableRowIndex;
  set csTableRowIndex(int value) {
    _csTableRowIndex = value;
  }

  int _pesTableRowCount = 10;
  int get pesTableRowCount => _pesTableRowCount;
  set pesTableRowCount(int value) {
    _pesTableRowCount = value;
  }

  int _pesTableRowIndex = 0;
  int get pesTableRowIndex => _pesTableRowIndex;
  set pesTableRowIndex(int value) {
    _pesTableRowIndex = value;
  }

  int _gsTableRowCount = 10;
  int get gsTableRowCount => _gsTableRowCount;
  set gsTableRowCount(int value) {
    _gsTableRowCount = value;
  }

  int _gsTableRowIndex = 0;
  int get gsTableRowIndex => _gsTableRowIndex;
  set gsTableRowIndex(int value) {
    _gsTableRowIndex = value;
  }

  String _csFilterDropDownContent = '';
  String get csFilterDropDownContent => _csFilterDropDownContent;
  set csFilterDropDownContent(String value) {
    _csFilterDropDownContent = value;
  }

  String _csFilterDropDownIndex = '';
  String get csFilterDropDownIndex => _csFilterDropDownIndex;
  set csFilterDropDownIndex(String value) {
    _csFilterDropDownIndex = value;
  }

  String _pesFilterDropDownIndex = '';
  String get pesFilterDropDownIndex => _pesFilterDropDownIndex;
  set pesFilterDropDownIndex(String value) {
    _pesFilterDropDownIndex = value;
  }

  String _pesFilterDropDownContent = '';
  String get pesFilterDropDownContent => _pesFilterDropDownContent;
  set pesFilterDropDownContent(String value) {
    _pesFilterDropDownContent = value;
  }

  bool _transferPatient = false;
  bool get transferPatient => _transferPatient;
  set transferPatient(bool value) {
    _transferPatient = value;
  }

  String _csFilterDropDownCCMIndex = '';
  String get csFilterDropDownCCMIndex => _csFilterDropDownCCMIndex;
  set csFilterDropDownCCMIndex(String value) {
    _csFilterDropDownCCMIndex = value;
  }

  String _csFilterDropDownRPMIndex = '';
  String get csFilterDropDownRPMIndex => _csFilterDropDownRPMIndex;
  set csFilterDropDownRPMIndex(String value) {
    _csFilterDropDownRPMIndex = value;
  }

  String _countdownValue = '';
  String get countdownValue => _countdownValue;
  set countdownValue(String value) {
    _countdownValue = value;
  }

  String _deviceTypeIndex = '';
  String get deviceTypeIndex => _deviceTypeIndex;
  set deviceTypeIndex(String value) {
    _deviceTypeIndex = value;
  }

  String _redirectURL = '';
  String get redirectURL => _redirectURL;
  set redirectURL(String value) {
    _redirectURL = value;
    secureStorage.setString('ff_redirectURL', value);
  }

  void deleteRedirectURL() {
    secureStorage.delete(key: 'ff_redirectURL');
  }

  int _totalTransferAlertCount = 0;
  int get totalTransferAlertCount => _totalTransferAlertCount;
  set totalTransferAlertCount(int value) {
    _totalTransferAlertCount = value;
  }

  int _patientID = 0;
  int get patientID => _patientID;
  set patientID(int value) {
    _patientID = value;
  }

  List<dynamic> _transferredPatientList = [];
  List<dynamic> get transferredPatientList => _transferredPatientList;
  set transferredPatientList(List<dynamic> value) {
    _transferredPatientList = value;
  }

  void addToTransferredPatientList(dynamic value) {
    transferredPatientList.add(value);
  }

  void removeFromTransferredPatientList(dynamic value) {
    transferredPatientList.remove(value);
  }

  void removeAtIndexFromTransferredPatientList(int index) {
    transferredPatientList.removeAt(index);
  }

  void updateTransferredPatientListAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    transferredPatientList[index] = updateFn(_transferredPatientList[index]);
  }

  void insertAtIndexInTransferredPatientList(int index, dynamic value) {
    transferredPatientList.insert(index, value);
  }

  bool _vpeActionTasks = false;
  bool get vpeActionTasks => _vpeActionTasks;
  set vpeActionTasks(bool value) {
    _vpeActionTasks = value;
  }

  double _countdownProgressBarValue = 1.0;
  double get countdownProgressBarValue => _countdownProgressBarValue;
  set countdownProgressBarValue(double value) {
    _countdownProgressBarValue = value;
  }

  String _acceptedTransferCSName = '';
  String get acceptedTransferCSName => _acceptedTransferCSName;
  set acceptedTransferCSName(String value) {
    _acceptedTransferCSName = value;
  }

  int _transferCSRequestCount = 0;
  int get transferCSRequestCount => _transferCSRequestCount;
  set transferCSRequestCount(int value) {
    _transferCSRequestCount = value;
  }

  String _isGlobalSearchCSListCompleted = 'Save';
  String get isGlobalSearchCSListCompleted => _isGlobalSearchCSListCompleted;
  set isGlobalSearchCSListCompleted(String value) {
    _isGlobalSearchCSListCompleted = value;
  }

  bool _isCSView = false;
  bool get isCSView => _isCSView;
  set isCSView(bool value) {
    _isCSView = value;
  }

  bool _isCSAdminView = false;
  bool get isCSAdminView => _isCSAdminView;
  set isCSAdminView(bool value) {
    _isCSAdminView = value;
  }

  List<String> _csSelectedStatusesCCM = [];
  List<String> get csSelectedStatusesCCM => _csSelectedStatusesCCM;
  set csSelectedStatusesCCM(List<String> value) {
    _csSelectedStatusesCCM = value;
  }

  void addToCsSelectedStatusesCCM(String value) {
    csSelectedStatusesCCM.add(value);
  }

  void removeFromCsSelectedStatusesCCM(String value) {
    csSelectedStatusesCCM.remove(value);
  }

  void removeAtIndexFromCsSelectedStatusesCCM(int index) {
    csSelectedStatusesCCM.removeAt(index);
  }

  void updateCsSelectedStatusesCCMAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    csSelectedStatusesCCM[index] = updateFn(_csSelectedStatusesCCM[index]);
  }

  void insertAtIndexInCsSelectedStatusesCCM(int index, String value) {
    csSelectedStatusesCCM.insert(index, value);
  }

  List<String> _csFilterDropdownContentListCCM = [];
  List<String> get csFilterDropdownContentListCCM =>
      _csFilterDropdownContentListCCM;
  set csFilterDropdownContentListCCM(List<String> value) {
    _csFilterDropdownContentListCCM = value;
  }

  void addToCsFilterDropdownContentListCCM(String value) {
    csFilterDropdownContentListCCM.add(value);
  }

  void removeFromCsFilterDropdownContentListCCM(String value) {
    csFilterDropdownContentListCCM.remove(value);
  }

  void removeAtIndexFromCsFilterDropdownContentListCCM(int index) {
    csFilterDropdownContentListCCM.removeAt(index);
  }

  void updateCsFilterDropdownContentListCCMAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    csFilterDropdownContentListCCM[index] =
        updateFn(_csFilterDropdownContentListCCM[index]);
  }

  void insertAtIndexInCsFilterDropdownContentListCCM(int index, String value) {
    csFilterDropdownContentListCCM.insert(index, value);
  }

  List<String> _csFilterDropdownContentListRPM = [];
  List<String> get csFilterDropdownContentListRPM =>
      _csFilterDropdownContentListRPM;
  set csFilterDropdownContentListRPM(List<String> value) {
    _csFilterDropdownContentListRPM = value;
  }

  void addToCsFilterDropdownContentListRPM(String value) {
    csFilterDropdownContentListRPM.add(value);
  }

  void removeFromCsFilterDropdownContentListRPM(String value) {
    csFilterDropdownContentListRPM.remove(value);
  }

  void removeAtIndexFromCsFilterDropdownContentListRPM(int index) {
    csFilterDropdownContentListRPM.removeAt(index);
  }

  void updateCsFilterDropdownContentListRPMAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    csFilterDropdownContentListRPM[index] =
        updateFn(_csFilterDropdownContentListRPM[index]);
  }

  void insertAtIndexInCsFilterDropdownContentListRPM(int index, String value) {
    csFilterDropdownContentListRPM.insert(index, value);
  }

  List<String> _pesFilterDropDownContentListCCM = [];
  List<String> get pesFilterDropDownContentListCCM =>
      _pesFilterDropDownContentListCCM;
  set pesFilterDropDownContentListCCM(List<String> value) {
    _pesFilterDropDownContentListCCM = value;
  }

  void addToPesFilterDropDownContentListCCM(String value) {
    pesFilterDropDownContentListCCM.add(value);
  }

  void removeFromPesFilterDropDownContentListCCM(String value) {
    pesFilterDropDownContentListCCM.remove(value);
  }

  void removeAtIndexFromPesFilterDropDownContentListCCM(int index) {
    pesFilterDropDownContentListCCM.removeAt(index);
  }

  void updatePesFilterDropDownContentListCCMAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    pesFilterDropDownContentListCCM[index] =
        updateFn(_pesFilterDropDownContentListCCM[index]);
  }

  void insertAtIndexInPesFilterDropDownContentListCCM(int index, String value) {
    pesFilterDropDownContentListCCM.insert(index, value);
  }

  List<String> _pesFilterDropDownContentListRPM = [];
  List<String> get pesFilterDropDownContentListRPM =>
      _pesFilterDropDownContentListRPM;
  set pesFilterDropDownContentListRPM(List<String> value) {
    _pesFilterDropDownContentListRPM = value;
  }

  void addToPesFilterDropDownContentListRPM(String value) {
    pesFilterDropDownContentListRPM.add(value);
  }

  void removeFromPesFilterDropDownContentListRPM(String value) {
    pesFilterDropDownContentListRPM.remove(value);
  }

  void removeAtIndexFromPesFilterDropDownContentListRPM(int index) {
    pesFilterDropDownContentListRPM.removeAt(index);
  }

  void updatePesFilterDropDownContentListRPMAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    pesFilterDropDownContentListRPM[index] =
        updateFn(_pesFilterDropDownContentListRPM[index]);
  }

  void insertAtIndexInPesFilterDropDownContentListRPM(int index, String value) {
    pesFilterDropDownContentListRPM.insert(index, value);
  }

  List<String> _csSelectedStatusesRPM = [];
  List<String> get csSelectedStatusesRPM => _csSelectedStatusesRPM;
  set csSelectedStatusesRPM(List<String> value) {
    _csSelectedStatusesRPM = value;
  }

  void addToCsSelectedStatusesRPM(String value) {
    csSelectedStatusesRPM.add(value);
  }

  void removeFromCsSelectedStatusesRPM(String value) {
    csSelectedStatusesRPM.remove(value);
  }

  void removeAtIndexFromCsSelectedStatusesRPM(int index) {
    csSelectedStatusesRPM.removeAt(index);
  }

  void updateCsSelectedStatusesRPMAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    csSelectedStatusesRPM[index] = updateFn(_csSelectedStatusesRPM[index]);
  }

  void insertAtIndexInCsSelectedStatusesRPM(int index, String value) {
    csSelectedStatusesRPM.insert(index, value);
  }

  List<String> _pesSelectedStatusesCCM = [];
  List<String> get pesSelectedStatusesCCM => _pesSelectedStatusesCCM;
  set pesSelectedStatusesCCM(List<String> value) {
    _pesSelectedStatusesCCM = value;
  }

  void addToPesSelectedStatusesCCM(String value) {
    pesSelectedStatusesCCM.add(value);
  }

  void removeFromPesSelectedStatusesCCM(String value) {
    pesSelectedStatusesCCM.remove(value);
  }

  void removeAtIndexFromPesSelectedStatusesCCM(int index) {
    pesSelectedStatusesCCM.removeAt(index);
  }

  void updatePesSelectedStatusesCCMAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    pesSelectedStatusesCCM[index] = updateFn(_pesSelectedStatusesCCM[index]);
  }

  void insertAtIndexInPesSelectedStatusesCCM(int index, String value) {
    pesSelectedStatusesCCM.insert(index, value);
  }

  List<String> _pesSelectedStatusesRPM = [];
  List<String> get pesSelectedStatusesRPM => _pesSelectedStatusesRPM;
  set pesSelectedStatusesRPM(List<String> value) {
    _pesSelectedStatusesRPM = value;
  }

  void addToPesSelectedStatusesRPM(String value) {
    pesSelectedStatusesRPM.add(value);
  }

  void removeFromPesSelectedStatusesRPM(String value) {
    pesSelectedStatusesRPM.remove(value);
  }

  void removeAtIndexFromPesSelectedStatusesRPM(int index) {
    pesSelectedStatusesRPM.removeAt(index);
  }

  void updatePesSelectedStatusesRPMAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    pesSelectedStatusesRPM[index] = updateFn(_pesSelectedStatusesRPM[index]);
  }

  void insertAtIndexInPesSelectedStatusesRPM(int index, String value) {
    pesSelectedStatusesRPM.insert(index, value);
  }

  String _csFilterSelectedKey = '';
  String get csFilterSelectedKey => _csFilterSelectedKey;
  set csFilterSelectedKey(String value) {
    _csFilterSelectedKey = value;
  }

  bool _filterApplied = false;
  bool get filterApplied => _filterApplied;
  set filterApplied(bool value) {
    _filterApplied = value;
  }

  String _twilioVoiceToken = '';
  String get twilioVoiceToken => _twilioVoiceToken;
  set twilioVoiceToken(String value) {
    _twilioVoiceToken = value;
    secureStorage.setString('ff_twilioVoiceToken', value);
  }

  void deleteTwilioVoiceToken() {
    secureStorage.delete(key: 'ff_twilioVoiceToken');
  }

  String _clinicID = '';
  String get clinicID => _clinicID;
  set clinicID(String value) {
    _clinicID = value;
  }

  String _patientClinicDataID = '';
  String get patientClinicDataID => _patientClinicDataID;
  set patientClinicDataID(String value) {
    _patientClinicDataID = value;
  }

  String _twilioCTCPhoneNo = '';
  String get twilioCTCPhoneNo => _twilioCTCPhoneNo;
  set twilioCTCPhoneNo(String value) {
    _twilioCTCPhoneNo = value;
    secureStorage.setString('ff_twilioCTCPhoneNo', value);
  }

  void deleteTwilioCTCPhoneNo() {
    secureStorage.delete(key: 'ff_twilioCTCPhoneNo');
  }

  bool _isPatientCallInProgress = false;
  bool get isPatientCallInProgress => _isPatientCallInProgress;
  set isPatientCallInProgress(bool value) {
    _isPatientCallInProgress = value;
    secureStorage.setBool('ff_isPatientCallInProgress', value);
  }

  void deleteIsPatientCallInProgress() {
    secureStorage.delete(key: 'ff_isPatientCallInProgress');
  }

  TwilioCallDataStruct _twilioCallData =
      TwilioCallDataStruct.fromSerializableMap(
          jsonDecode('{\"originNumberType\":\"goulb\"}'));
  TwilioCallDataStruct get twilioCallData => _twilioCallData;
  set twilioCallData(TwilioCallDataStruct value) {
    _twilioCallData = value;
    secureStorage.setString('ff_twilioCallData', value.serialize());
  }

  void deleteTwilioCallData() {
    secureStorage.delete(key: 'ff_twilioCallData');
  }

  void updateTwilioCallDataStruct(Function(TwilioCallDataStruct) updateFn) {
    updateFn(_twilioCallData);
    secureStorage.setString('ff_twilioCallData', _twilioCallData.serialize());
  }

  String _csFilterDeferredDropDownContent = '';
  String get csFilterDeferredDropDownContent =>
      _csFilterDeferredDropDownContent;
  set csFilterDeferredDropDownContent(String value) {
    _csFilterDeferredDropDownContent = value;
  }

  String _csFilterFollowUpDropDownContent = '';
  String get csFilterFollowUpDropDownContent =>
      _csFilterFollowUpDropDownContent;
  set csFilterFollowUpDropDownContent(String value) {
    _csFilterFollowUpDropDownContent = value;
  }

  String _csFilterDeferredDropDownIndex = '';
  String get csFilterDeferredDropDownIndex => _csFilterDeferredDropDownIndex;
  set csFilterDeferredDropDownIndex(String value) {
    _csFilterDeferredDropDownIndex = value;
  }

  String _csFilterFollowUpDropDownIndex = '';
  String get csFilterFollowUpDropDownIndex => _csFilterFollowUpDropDownIndex;
  set csFilterFollowUpDropDownIndex(String value) {
    _csFilterFollowUpDropDownIndex = value;
  }

  final _listOfESManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> listOfES({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _listOfESManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearListOfESCache() => _listOfESManager.clear();
  void clearListOfESCacheKey(String? uniqueKey) =>
      _listOfESManager.clearRequest(uniqueKey);

  final _groupTypeManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> groupType({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _groupTypeManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearGroupTypeCache() => _groupTypeManager.clear();
  void clearGroupTypeCacheKey(String? uniqueKey) =>
      _groupTypeManager.clearRequest(uniqueKey);

  final _groupStatusManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> groupStatus({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _groupStatusManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearGroupStatusCache() => _groupStatusManager.clear();
  void clearGroupStatusCacheKey(String? uniqueKey) =>
      _groupStatusManager.clearRequest(uniqueKey);

  final _clinicsWithoutActiveEnrollerManager =
      FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> clinicsWithoutActiveEnroller({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _clinicsWithoutActiveEnrollerManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearClinicsWithoutActiveEnrollerCache() =>
      _clinicsWithoutActiveEnrollerManager.clear();
  void clearClinicsWithoutActiveEnrollerCacheKey(String? uniqueKey) =>
      _clinicsWithoutActiveEnrollerManager.clearRequest(uniqueKey);

  final _allClinicsManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> allClinics({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _allClinicsManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearAllClinicsCache() => _allClinicsManager.clear();
  void clearAllClinicsCacheKey(String? uniqueKey) =>
      _allClinicsManager.clearRequest(uniqueKey);

  final _careSpecialistListManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> careSpecialistList({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _careSpecialistListManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearCareSpecialistListCache() => _careSpecialistListManager.clear();
  void clearCareSpecialistListCacheKey(String? uniqueKey) =>
      _careSpecialistListManager.clearRequest(uniqueKey);

  final _patientEnrollmentListManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> patientEnrollmentList({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _patientEnrollmentListManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearPatientEnrollmentListCache() =>
      _patientEnrollmentListManager.clear();
  void clearPatientEnrollmentListCacheKey(String? uniqueKey) =>
      _patientEnrollmentListManager.clearRequest(uniqueKey);

  final _globalSearchPatientCallDetailsManager =
      FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> globalSearchPatientCallDetails({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _globalSearchPatientCallDetailsManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearGlobalSearchPatientCallDetailsCache() =>
      _globalSearchPatientCallDetailsManager.clear();
  void clearGlobalSearchPatientCallDetailsCacheKey(String? uniqueKey) =>
      _globalSearchPatientCallDetailsManager.clearRequest(uniqueKey);

  final _apptDateManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> apptDate({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _apptDateManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearApptDateCache() => _apptDateManager.clear();
  void clearApptDateCacheKey(String? uniqueKey) =>
      _apptDateManager.clearRequest(uniqueKey);

  final _apptTimeManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> apptTime({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _apptTimeManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearApptTimeCache() => _apptTimeManager.clear();
  void clearApptTimeCacheKey(String? uniqueKey) =>
      _apptTimeManager.clearRequest(uniqueKey);

  final _vpePatientDetailsCacheManager =
      FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> vpePatientDetailsCache({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _vpePatientDetailsCacheManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearVpePatientDetailsCacheCache() =>
      _vpePatientDetailsCacheManager.clear();
  void clearVpePatientDetailsCacheCacheKey(String? uniqueKey) =>
      _vpePatientDetailsCacheManager.clearRequest(uniqueKey);

  final _vPEListManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> vPEList({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _vPEListManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearVPEListCache() => _vPEListManager.clear();
  void clearVPEListCacheKey(String? uniqueKey) =>
      _vPEListManager.clearRequest(uniqueKey);

  final _ccmStatusUpdatesGSManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> ccmStatusUpdatesGS({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _ccmStatusUpdatesGSManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearCcmStatusUpdatesGSCache() => _ccmStatusUpdatesGSManager.clear();
  void clearCcmStatusUpdatesGSCacheKey(String? uniqueKey) =>
      _ccmStatusUpdatesGSManager.clearRequest(uniqueKey);

  final _facilityListManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> facilityList({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _facilityListManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearFacilityListCache() => _facilityListManager.clear();
  void clearFacilityListCacheKey(String? uniqueKey) =>
      _facilityListManager.clearRequest(uniqueKey);

  final _rpmStatusListGSManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> rpmStatusListGS({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _rpmStatusListGSManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearRpmStatusListGSCache() => _rpmStatusListGSManager.clear();
  void clearRpmStatusListGSCacheKey(String? uniqueKey) =>
      _rpmStatusListGSManager.clearRequest(uniqueKey);

  final _ccmStatusListVPEManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> ccmStatusListVPE({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _ccmStatusListVPEManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearCcmStatusListVPECache() => _ccmStatusListVPEManager.clear();
  void clearCcmStatusListVPECacheKey(String? uniqueKey) =>
      _ccmStatusListVPEManager.clearRequest(uniqueKey);

  final _ccmStatusUpdateDeferredVpeManager =
      FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> ccmStatusUpdateDeferredVpe({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _ccmStatusUpdateDeferredVpeManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearCcmStatusUpdateDeferredVpeCache() =>
      _ccmStatusUpdateDeferredVpeManager.clear();
  void clearCcmStatusUpdateDeferredVpeCacheKey(String? uniqueKey) =>
      _ccmStatusUpdateDeferredVpeManager.clearRequest(uniqueKey);

  final _ccmStatusUpdatesVPEManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> ccmStatusUpdatesVPE({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _ccmStatusUpdatesVPEManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearCcmStatusUpdatesVPECache() => _ccmStatusUpdatesVPEManager.clear();
  void clearCcmStatusUpdatesVPECacheKey(String? uniqueKey) =>
      _ccmStatusUpdatesVPEManager.clearRequest(uniqueKey);

  final _ccmStatusUpdatesCSManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> ccmStatusUpdatesCS({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _ccmStatusUpdatesCSManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearCcmStatusUpdatesCSCache() => _ccmStatusUpdatesCSManager.clear();
  void clearCcmStatusUpdatesCSCacheKey(String? uniqueKey) =>
      _ccmStatusUpdatesCSManager.clearRequest(uniqueKey);

  final _patientDetailsCacheManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> patientDetailsCache({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _patientDetailsCacheManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearPatientDetailsCacheCache() => _patientDetailsCacheManager.clear();
  void clearPatientDetailsCacheCacheKey(String? uniqueKey) =>
      _patientDetailsCacheManager.clearRequest(uniqueKey);

  final _rpmStatusListCSManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> rpmStatusListCS({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _rpmStatusListCSManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearRpmStatusListCSCache() => _rpmStatusListCSManager.clear();
  void clearRpmStatusListCSCacheKey(String? uniqueKey) =>
      _rpmStatusListCSManager.clearRequest(uniqueKey);

  final _rpmStatusUpdatesPESManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> rpmStatusUpdatesPES({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _rpmStatusUpdatesPESManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearRpmStatusUpdatesPESCache() => _rpmStatusUpdatesPESManager.clear();
  void clearRpmStatusUpdatesPESCacheKey(String? uniqueKey) =>
      _rpmStatusUpdatesPESManager.clearRequest(uniqueKey);

  final _listOfCareSpecialistCallStatusManager =
      FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> listOfCareSpecialistCallStatus({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _listOfCareSpecialistCallStatusManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearListOfCareSpecialistCallStatusCache() =>
      _listOfCareSpecialistCallStatusManager.clear();
  void clearListOfCareSpecialistCallStatusCacheKey(String? uniqueKey) =>
      _listOfCareSpecialistCallStatusManager.clearRequest(uniqueKey);

  final _virtualEnrollmentSpecialistManager =
      FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> virtualEnrollmentSpecialist({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _virtualEnrollmentSpecialistManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearVirtualEnrollmentSpecialistCache() =>
      _virtualEnrollmentSpecialistManager.clear();
  void clearVirtualEnrollmentSpecialistCacheKey(String? uniqueKey) =>
      _virtualEnrollmentSpecialistManager.clearRequest(uniqueKey);

  final _listOfGsPatientsManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> listOfGsPatients({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _listOfGsPatientsManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearListOfGsPatientsCache() => _listOfGsPatientsManager.clear();
  void clearListOfGsPatientsCacheKey(String? uniqueKey) =>
      _listOfGsPatientsManager.clearRequest(uniqueKey);

  final _duplicateGroupDetailsManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> duplicateGroupDetails({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _duplicateGroupDetailsManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearDuplicateGroupDetailsCache() =>
      _duplicateGroupDetailsManager.clear();
  void clearDuplicateGroupDetailsCacheKey(String? uniqueKey) =>
      _duplicateGroupDetailsManager.clearRequest(uniqueKey);

  final _getFacilityByClinicManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> getFacilityByClinic({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _getFacilityByClinicManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearGetFacilityByClinicCache() => _getFacilityByClinicManager.clear();
  void clearGetFacilityByClinicCacheKey(String? uniqueKey) =>
      _getFacilityByClinicManager.clearRequest(uniqueKey);

  final _providerListManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> providerList({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _providerListManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearProviderListCache() => _providerListManager.clear();
  void clearProviderListCacheKey(String? uniqueKey) =>
      _providerListManager.clearRequest(uniqueKey);

  final _ccmStatusUpdatesManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> ccmStatusUpdates({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _ccmStatusUpdatesManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearCcmStatusUpdatesCache() => _ccmStatusUpdatesManager.clear();
  void clearCcmStatusUpdatesCacheKey(String? uniqueKey) =>
      _ccmStatusUpdatesManager.clearRequest(uniqueKey);

  final _rpmStatusUpdatesManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> rpmStatusUpdates({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _rpmStatusUpdatesManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearRpmStatusUpdatesCache() => _rpmStatusUpdatesManager.clear();
  void clearRpmStatusUpdatesCacheKey(String? uniqueKey) =>
      _rpmStatusUpdatesManager.clearRequest(uniqueKey);

  final _ccmStatusListManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> ccmStatusList({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _ccmStatusListManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearCcmStatusListCache() => _ccmStatusListManager.clear();
  void clearCcmStatusListCacheKey(String? uniqueKey) =>
      _ccmStatusListManager.clearRequest(uniqueKey);

  final _rpmStatusListManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> rpmStatusList({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _rpmStatusListManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearRpmStatusListCache() => _rpmStatusListManager.clear();
  void clearRpmStatusListCacheKey(String? uniqueKey) =>
      _rpmStatusListManager.clearRequest(uniqueKey);

  final _rpmStatusUpdatesGSManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> rpmStatusUpdatesGS({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _rpmStatusUpdatesGSManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearRpmStatusUpdatesGSCache() => _rpmStatusUpdatesGSManager.clear();
  void clearRpmStatusUpdatesGSCacheKey(String? uniqueKey) =>
      _rpmStatusUpdatesGSManager.clearRequest(uniqueKey);

  final _ccmStatusListGSManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> ccmStatusListGS({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _ccmStatusListGSManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearCcmStatusListGSCache() => _ccmStatusListGSManager.clear();
  void clearCcmStatusListGSCacheKey(String? uniqueKey) =>
      _ccmStatusListGSManager.clearRequest(uniqueKey);

  final _rpmStatusUpdatesCSManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> rpmStatusUpdatesCS({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _rpmStatusUpdatesCSManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearRpmStatusUpdatesCSCache() => _rpmStatusUpdatesCSManager.clear();
  void clearRpmStatusUpdatesCSCacheKey(String? uniqueKey) =>
      _rpmStatusUpdatesCSManager.clearRequest(uniqueKey);

  final _ccmStatusListCSManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> ccmStatusListCS({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _ccmStatusListCSManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearCcmStatusListCSCache() => _ccmStatusListCSManager.clear();
  void clearCcmStatusListCSCacheKey(String? uniqueKey) =>
      _ccmStatusListCSManager.clearRequest(uniqueKey);

  final _rpmStatusListPESManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> rpmStatusListPES({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _rpmStatusListPESManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearRpmStatusListPESCache() => _rpmStatusListPESManager.clear();
  void clearRpmStatusListPESCacheKey(String? uniqueKey) =>
      _rpmStatusListPESManager.clearRequest(uniqueKey);

  final _conditionListManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> conditionList({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _conditionListManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearConditionListCache() => _conditionListManager.clear();
  void clearConditionListCacheKey(String? uniqueKey) =>
      _conditionListManager.clearRequest(uniqueKey);

  final _vpeDeferredPatientsCacheManager =
      FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> vpeDeferredPatientsCache({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _vpeDeferredPatientsCacheManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearVpeDeferredPatientsCacheCache() =>
      _vpeDeferredPatientsCacheManager.clear();
  void clearVpeDeferredPatientsCacheCacheKey(String? uniqueKey) =>
      _vpeDeferredPatientsCacheManager.clearRequest(uniqueKey);

  final _ccmStatusListDeferredVPEManager =
      FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> ccmStatusListDeferredVPE({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _ccmStatusListDeferredVPEManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearCcmStatusListDeferredVPECache() =>
      _ccmStatusListDeferredVPEManager.clear();
  void clearCcmStatusListDeferredVPECacheKey(String? uniqueKey) =>
      _ccmStatusListDeferredVPEManager.clearRequest(uniqueKey);

  final _canCallManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> canCall({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _canCallManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearCanCallCache() => _canCallManager.clear();
  void clearCanCallCacheKey(String? uniqueKey) =>
      _canCallManager.clearRequest(uniqueKey);
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}

extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  static final _lock = Lock();

  Future<void> writeSync({required String key, String? value}) async =>
      await _lock.synchronized(() async {
        await write(key: key, value: value);
      });

  void remove(String key) => delete(key: key);

  Future<String?> getString(String key) async => await read(key: key);
  Future<void> setString(String key, String value) async =>
      await writeSync(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';
  Future<void> setBool(String key, bool value) async =>
      await writeSync(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');
  Future<void> setInt(String key, int value) async =>
      await writeSync(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');
  Future<void> setDouble(String key, double value) async =>
      await writeSync(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });
  Future<void> setStringList(String key, List<String> value) async =>
      await writeSync(key: key, value: ListToCsvConverter().convert([value]));
}
