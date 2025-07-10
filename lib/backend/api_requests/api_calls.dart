import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start PEP APIs Group Code

class PEPAPIsGroup {
  static String getBaseUrl({
    String? authToken = '',
    String? baseURL,
  }) {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    return '${baseURL}/api/pep';
  }

  static Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer [authToken]',
  };
  static DeleteGroupCall deleteGroupCall = DeleteGroupCall();
  static CreateGroupCall createGroupCall = CreateGroupCall();
  static CreateGroupByEMRCall createGroupByEMRCall = CreateGroupByEMRCall();
  static SendSMSCall sendSMSCall = SendSMSCall();
  static SendEmailCall sendEmailCall = SendEmailCall();
  static UpdateGroupCall updateGroupCall = UpdateGroupCall();
  static ArchiveGroupCall archiveGroupCall = ArchiveGroupCall();
  static UpdatePatientByESCall updatePatientByESCall = UpdatePatientByESCall();
  static UpdatePatientByCSCall updatePatientByCSCall = UpdatePatientByCSCall();
  static UpdatePatientByPESCall updatePatientByPESCall =
      UpdatePatientByPESCall();
  static CreateVPECall createVPECall = CreateVPECall();
  static CreateTimerLogCall createTimerLogCall = CreateTimerLogCall();
  static UpdateTimerLogCall updateTimerLogCall = UpdateTimerLogCall();
  static UpdatePESCall updatePESCall = UpdatePESCall();
  static UpdateCSCall updateCSCall = UpdateCSCall();
  static UpdateVPECall updateVPECall = UpdateVPECall();
  static DeletePESCall deletePESCall = DeletePESCall();
  static DeleteVPECall deleteVPECall = DeleteVPECall();
  static DeleteCSCall deleteCSCall = DeleteCSCall();
  static DeleteTimeSlotCall deleteTimeSlotCall = DeleteTimeSlotCall();
  static CreateClinicAppointmentsCall createClinicAppointmentsCall =
      CreateClinicAppointmentsCall();
  static UpdatePatientCall updatePatientCall = UpdatePatientCall();
  static UpdateTransferredPatientCall updateTransferredPatientCall =
      UpdateTransferredPatientCall();
  static UnlockPatientCall unlockPatientCall = UnlockPatientCall();
  static InvalidateTransferredPatientCall invalidateTransferredPatientCall =
      InvalidateTransferredPatientCall();
  static LockPatientCall lockPatientCall = LockPatientCall();
  static LockPatientByGroupCall lockPatientByGroupCall =
      LockPatientByGroupCall();
  static ApprovePatientTransferRequestCall approvePatientTransferRequestCall =
      ApprovePatientTransferRequestCall();
  static CreatePESCall createPESCall = CreatePESCall();
  static CreateCSCall createCSCall = CreateCSCall();
  static DeleteMultipleTimeSlotsCall deleteMultipleTimeSlotsCall =
      DeleteMultipleTimeSlotsCall();
  static CreatePatientTimerLogCall createPatientTimerLogCall =
      CreatePatientTimerLogCall();
  static UpdatePatientTimerLogCall updatePatientTimerLogCall =
      UpdatePatientTimerLogCall();
}

class DeleteGroupCall {
  Future<ApiCallResponse> call({
    String? enrollmentAdminId = '',
    int? groupId,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'Delete Group',
      apiUrl: '${baseUrl}/${enrollmentAdminId}/ga/${groupId}',
      callType: ApiCallType.DELETE,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CreateGroupCall {
  Future<ApiCallResponse> call({
    String? name = '',
    int? type,
    int? status,
    int? clinicId,
    List<int>? enrollmentSpecialistIdList,
    List<int>? patientIdsList,
    String? enrollmentAdminId = '',
    dynamic groupFiltersJson,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );
    final enrollmentSpecialistId = _serializeList(enrollmentSpecialistIdList);
    final patientIds = _serializeList(patientIdsList);
    final groupFilters = _serializeJson(groupFiltersJson);
    final ffApiRequestBody = '''
{
  "name": "${name}",
  "type": ${type},
  "status": ${status},
  "clinic_id": ${clinicId},
  "enrollment_specialist_id": ${enrollmentSpecialistId},
  "patient_ids": ${patientIds},
  "group_filters": ${groupFilters}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Group',
      apiUrl: '${baseUrl}/${enrollmentAdminId}/ga',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? status(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class CreateGroupByEMRCall {
  Future<ApiCallResponse> call({
    String? name = '',
    int? type,
    int? status,
    int? clinicId,
    List<int>? enrollmentSpecialistIdList,
    List<int>? patientIdsList,
    String? enrollmentAdminId = '',
    dynamic groupFiltersJson,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );
    final enrollmentSpecialistId = _serializeList(enrollmentSpecialistIdList);
    final patientIds = _serializeList(patientIdsList);
    final groupFilters = _serializeJson(groupFiltersJson);
    final ffApiRequestBody = '''
{
  "name": "${name}",
  "type": ${type},
  "status": ${status},
  "clinic_id": ${clinicId},
  "enrollment_specialist_id": ${enrollmentSpecialistId},
  "patient_ids": ${patientIds},
  "group_filters": ${groupFilters}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Group by EMR',
      apiUrl: '${baseUrl}/${enrollmentAdminId}/ga',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? status(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class SendSMSCall {
  Future<ApiCallResponse> call({
    String? phoneNumber = '',
    String? smsTemplate = '',
    String? enrollmentAdminId = '',
    String? patientId = '',
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    final ffApiRequestBody = '''
{
  "phoneNumber": "${phoneNumber}",
  "smsTemplate": "${smsTemplate}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Send SMS',
      apiUrl: '${baseUrl}/${enrollmentAdminId}/appInviteLink/${patientId}',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? status(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class SendEmailCall {
  Future<ApiCallResponse> call({
    List<String>? emailList,
    String? password = '',
    String? enrollmentAdminId = '',
    String? groupId = '',
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );
    final email = _serializeList(emailList);

    final ffApiRequestBody = '''
{
  "emails": ${email},
  "password": "${password}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Send Email',
      apiUrl: '${baseUrl}/${enrollmentAdminId}/sendGroupDetails/${groupId}',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? status(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class UpdateGroupCall {
  Future<ApiCallResponse> call({
    String? enrollmentAdminId = '',
    int? groupId,
    String? name = '',
    int? type,
    List<int>? enrollmentSpecialistIdList,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );
    final enrollmentSpecialistId = _serializeList(enrollmentSpecialistIdList);

    final ffApiRequestBody = '''
{
  "name": "${name}",
  "type": ${type},
  "status": 2,
  "enrollment_specialist_id": ${enrollmentSpecialistId}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Group',
      apiUrl: '${baseUrl}/${enrollmentAdminId}/ga/${groupId}',
      callType: ApiCallType.PUT,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class ArchiveGroupCall {
  Future<ApiCallResponse> call({
    String? enrollmentAdminId = '',
    int? groupId,
    bool? archive,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    final ffApiRequestBody = '''
{
  "to_archive": ${archive}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Archive Group',
      apiUrl: '${baseUrl}/${enrollmentAdminId}/archiveGroup/${groupId}',
      callType: ApiCallType.PUT,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class UpdatePatientByESCall {
  Future<ApiCallResponse> call({
    int? enrollmentSpecialistId,
    int? patientClinicDataId,
    int? pepPatientId,
    int? groupId,
    String? firstName = '',
    String? lastName = '',
    String? mobileNumber = '',
    String? homeNumber = '',
    String? emailAddress = '',
    String? addressLine1 = '',
    String? city = '',
    String? state = '',
    String? zipCode = '',
    String? primaryInsurance = '',
    String? secondaryInsurance = '',
    String? primaryInsuranceNumber = '',
    String? secondaryInsuranceNumber = '',
    int? callStatus,
    String? comment = '',
    String? appointmentDate = '',
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    final ffApiRequestBody = '''
{
  "pep_patient_id": ${pepPatientId},
  "group_id": ${groupId},
  "first_name": "${firstName}",
  "last_name": "${lastName}",
  "mobile_number": "${mobileNumber}",
  "home_number": "${homeNumber}",
  "email_address": "${emailAddress}",
  "address_line_1": "${addressLine1}",
  "city": "${city}",
  "state": "${state}",
  "zip_code": "${zipCode}",
  "primary_insurance": "${primaryInsurance}",
  "secondary_insurance": "${secondaryInsurance}",
  "primary_insurance_number": "${primaryInsuranceNumber}",
  "secondary_insurance_number": "${secondaryInsuranceNumber}",
  "call_status": ${callStatus},
  "comment": "${comment}",
  "appointment_date": "${appointmentDate}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Patient by ES',
      apiUrl: '${baseUrl}/${enrollmentSpecialistId}/es/${patientClinicDataId}',
      callType: ApiCallType.PUT,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? updatePatientVPEStatus(dynamic response) =>
      castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class UpdatePatientByCSCall {
  Future<ApiCallResponse> call({
    int? careSpecialistId,
    int? patientClinicDataId,
    int? callStatus,
    int? clinicId,
    String? comment = '',
    List<String>? ccmVitalsList,
    String? appointmentDate = '',
    String? appointmentTime = '',
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );
    final ccmVitals = _serializeList(ccmVitalsList);

    final ffApiRequestBody = '''
{
  "call_status": ${callStatus},
  "clinic_id": ${clinicId},
  "comment": "${comment}",
  "ccm_vitals": ${ccmVitals},
  "appointment_date": "${appointmentDate}",
  "appointment_time": "${appointmentTime}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Patient by CS',
      apiUrl: '${baseUrl}/${careSpecialistId}/cs/${patientClinicDataId}',
      callType: ApiCallType.PUT,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdatePatientByPESCall {
  Future<ApiCallResponse> call({
    int? patientEnrollerId,
    int? patientClinicDataId,
    int? callStatus,
    int? clinicId,
    String? comment = '',
    String? appointmentDate = '',
    String? appointmentTime = '',
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    final ffApiRequestBody = '''
{
  "call_status": ${callStatus},
  "clinic_id": ${clinicId},
  "comment": "${comment}",
  "rpm_vitals": [],
  "appointment_date": "${appointmentDate}",
  "appointment_time": "${appointmentTime}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Patient by PES',
      apiUrl: '${baseUrl}/${patientEnrollerId}/pe/${patientClinicDataId}',
      callType: ApiCallType.PUT,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CreateVPECall {
  Future<ApiCallResponse> call({
    int? adminId,
    String? firstName = '',
    String? lastName = '',
    String? email = '',
    String? password = '',
    String? taskAssigned = '',
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    final ffApiRequestBody = '''
{
  "first_name": "${firstName}",
  "last_name": "${lastName}",
  "task_assigned" :"${taskAssigned}",
  "email": "${email}",
  "password": "${password}"
 }''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create VPE',
      apiUrl: '${baseUrl}/${adminId}/ea',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class CreateTimerLogCall {
  Future<ApiCallResponse> call({
    int? duration = 0,
    String? status = 'inprogress',
    String? userId = '',
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    final ffApiRequestBody = '''
{
  "duration": ${duration},
  "status": "${status}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Timer Log',
      apiUrl: '${baseUrl}/${userId}/timelog',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  int? timelogId(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.timeLogId''',
      ));
}

class UpdateTimerLogCall {
  Future<ApiCallResponse> call({
    int? duration = 0,
    String? status = 'inprogress',
    String? userId = '',
    String? timelogId = '',
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    final ffApiRequestBody = '''
{
  "duration": ${duration},
  "status": "${status}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Timer Log',
      apiUrl: '${baseUrl}/${userId}/timelog/${timelogId}',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class UpdatePESCall {
  Future<ApiCallResponse> call({
    int? adminId,
    int? patientEnrollerId,
    String? requestBody = '',
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    final ffApiRequestBody = '''
${requestBody}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update PES',
      apiUrl: '${baseUrl}/${adminId}/pa/${patientEnrollerId}',
      callType: ApiCallType.PUT,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateCSCall {
  Future<ApiCallResponse> call({
    int? adminId,
    int? careSpecialistId,
    String? requestBody = '',
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    final ffApiRequestBody = '''
${requestBody}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update CS',
      apiUrl: '${baseUrl}/${adminId}/ca/${careSpecialistId}',
      callType: ApiCallType.PUT,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateVPECall {
  Future<ApiCallResponse> call({
    int? adminId,
    int? vpeId,
    String? requestBody = '',
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    final ffApiRequestBody = '''
${requestBody}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update VPE',
      apiUrl: '${baseUrl}/${adminId}/ea/${vpeId}',
      callType: ApiCallType.PUT,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class DeletePESCall {
  Future<ApiCallResponse> call({
    int? adminId,
    int? patientEnrollerId,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'Delete PES',
      apiUrl: '${baseUrl}/${adminId}/pa/${patientEnrollerId}',
      callType: ApiCallType.DELETE,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class DeleteVPECall {
  Future<ApiCallResponse> call({
    int? adminId,
    int? vpeId,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'Delete VPE',
      apiUrl: '${baseUrl}/${adminId}/ea/${vpeId}',
      callType: ApiCallType.DELETE,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class DeleteCSCall {
  Future<ApiCallResponse> call({
    int? adminId,
    int? careSpecialistId,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'Delete CS',
      apiUrl: '${baseUrl}/${adminId}/ca/${careSpecialistId}',
      callType: ApiCallType.DELETE,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class DeleteTimeSlotCall {
  Future<ApiCallResponse> call({
    int? adminId,
    int? appointmentId,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'Delete Time Slot',
      apiUrl: '${baseUrl}/${adminId}/pa/appointment/${appointmentId}',
      callType: ApiCallType.DELETE,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? pesDeleteTimeSlotStatus(dynamic response) =>
      castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class CreateClinicAppointmentsCall {
  Future<ApiCallResponse> call({
    int? adminId,
    int? clinicId,
    List<String>? appointmentDatesList,
    String? startingTime = '',
    String? endingTime = '',
    int? duration,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );
    final appointmentDates = _serializeList(appointmentDatesList);

    final ffApiRequestBody = '''
{
  "appointment_dates": ${appointmentDates},
  "starting_time": "${startingTime}",
  "ending_time": "${endingTime}",
  "duration":${duration}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Clinic Appointments',
      apiUrl: '${baseUrl}/${adminId}/pa/appointment/${clinicId}',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdatePatientCall {
  Future<ApiCallResponse> call({
    int? loginID,
    int? patientClinicDataID,
    String? requestBody = '',
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    final ffApiRequestBody = '''
${requestBody}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Patient',
      apiUrl: '${baseUrl}/${loginID}/enrollment/${patientClinicDataID}',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? updatePatientVPEStatus(dynamic response) =>
      castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class UpdateTransferredPatientCall {
  Future<ApiCallResponse> call({
    int? loginID,
    int? patientClinicDataID,
    String? requestBody = '',
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    final ffApiRequestBody = '''
${requestBody}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Transferred Patient',
      apiUrl: '${baseUrl}/${loginID}/transferToCs/${patientClinicDataID}',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? transferPatientVPEStatus(dynamic response) =>
      castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.message''',
      ));
  int? transferId(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.transfer_id''',
      ));
}

class UnlockPatientCall {
  Future<ApiCallResponse> call({
    int? loginID,
    int? patientClinicDataID,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'Unlock Patient',
      apiUrl: '${baseUrl}/${loginID}/unlockPatient/${patientClinicDataID}',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      bodyType: BodyType.NONE,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? updatePatientVPEStatus(dynamic response) =>
      castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class InvalidateTransferredPatientCall {
  Future<ApiCallResponse> call({
    int? loginID,
    int? transferID,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'Invalidate Transferred Patient',
      apiUrl: '${baseUrl}/${loginID}/invalidateTransfer/${transferID}',
      callType: ApiCallType.PUT,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      bodyType: BodyType.NONE,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? updatePatientVPEStatus(dynamic response) =>
      castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class LockPatientCall {
  Future<ApiCallResponse> call({
    int? loginID,
    int? patientClinicDataID,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'Lock Patient',
      apiUrl: '${baseUrl}/${loginID}/lockPatient/${patientClinicDataID}',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      bodyType: BodyType.NONE,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? updatePatientVPEStatus(dynamic response) =>
      castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class LockPatientByGroupCall {
  Future<ApiCallResponse> call({
    int? loginID,
    int? groupId,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'Lock Patient By Group',
      apiUrl: '${baseUrl}/${loginID}/lockPatientByGroup/${groupId}',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      bodyType: BodyType.NONE,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? updatePatientVPEStatus(dynamic response) =>
      castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class ApprovePatientTransferRequestCall {
  Future<ApiCallResponse> call({
    String? enrollmentAdminId = '',
    String? transferId = '',
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'Approve Patient Transfer Request',
      apiUrl: '${baseUrl}/${enrollmentAdminId}/updateTransfer/${transferId}',
      callType: ApiCallType.PUT,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CreatePESCall {
  Future<ApiCallResponse> call({
    int? adminId,
    String? firstName = '',
    String? lastName = '',
    String? email = '',
    String? password = '',
    List<int>? clinicIdsList,
    bool? deferredTask,
    bool? followUpTask,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );
    final clinicIds = _serializeList(clinicIdsList);

    final ffApiRequestBody = '''
{
  "first_name": "${firstName}",
  "last_name": "${lastName}",
  "email": "${email}",
  "password": "${password}",
  "clinic_ids": ${clinicIds},
  "deferred_task": "${deferredTask}",
  "follow_up_task": "${followUpTask}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create PES ',
      apiUrl: '${baseUrl}/${adminId}/pa',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class CreateCSCall {
  Future<ApiCallResponse> call({
    int? adminId,
    String? firstName = '',
    String? lastName = '',
    String? email = '',
    String? password = '',
    List<int>? clinicIdsList,
    bool? deferredTask,
    bool? followUpTask,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );
    final clinicIds = _serializeList(clinicIdsList);

    final ffApiRequestBody = '''
{
  "first_name": "${firstName}",
  "last_name": "${lastName}",
  "deferred_task": "${deferredTask}",
  "follow_up_task": "${followUpTask}",
  "email": "${email}",
  "password": "${password}",
  "clinic_ids": ${clinicIds}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create CS',
      apiUrl: '${baseUrl}/${adminId}/ca',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class DeleteMultipleTimeSlotsCall {
  Future<ApiCallResponse> call({
    int? adminId,
    List<int>? appointmentIdsList,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );
    final appointmentIds = _serializeList(appointmentIdsList);

    final ffApiRequestBody = '''
{
  "appointmentIds": ${appointmentIds}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Delete Multiple Time Slots',
      apiUrl: '${baseUrl}/${adminId}/pa/deleteAppointments',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? pesDeleteMultipleTimeSlotStatus(dynamic response) =>
      castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class CreatePatientTimerLogCall {
  Future<ApiCallResponse> call({
    int? duration = 0,
    String? status = 'inprogress',
    String? userId = '',
    int? pepPatientId,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    final ffApiRequestBody = '''
{
  "duration": ${duration},
  "status": "${escapeStringForJson(status)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Patient Timer Log',
      apiUrl: '${baseUrl}/${userId}/patientTimelog/${pepPatientId}',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  int? timeLogId(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.timeLogId''',
      ));
  bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class UpdatePatientTimerLogCall {
  Future<ApiCallResponse> call({
    int? duration = 0,
    String? status = 'inprogress',
    String? userId = '',
    String? timelogId = '',
    int? pepPatientId,
    String? authToken = '',
    String? baseURL,
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = PEPAPIsGroup.getBaseUrl(
      authToken: authToken,
      baseURL: baseURL,
    );

    final ffApiRequestBody = '''
{
  "duration": ${duration},
  "status": "${escapeStringForJson(status)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Update Patient Timer Log',
      apiUrl:
          '${baseUrl}/${userId}/patientTimelog/${pepPatientId}/${timelogId}',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? sucess(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

/// End PEP APIs Group Code

/// Start Twilio Group Code

class TwilioGroup {
  static String getBaseUrl({
    String? baseURL,
    String? authToken = '',
  }) {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    return '${baseURL}/twilio';
  }

  static Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer [authToken]',
    'ngrok-skip-browser-warning': 'true',
  };
  static GetTokenCall getTokenCall = GetTokenCall();
  static TransferCall transferCall = TransferCall();
}

class GetTokenCall {
  Future<ApiCallResponse> call({
    String? baseURL,
    String? authToken = '',
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = TwilioGroup.getBaseUrl(
      baseURL: baseURL,
      authToken: authToken,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'Get Token',
      apiUrl: '${baseUrl}/token',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
        'ngrok-skip-browser-warning': 'true',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? token(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.token''',
      ));
}

class TransferCall {
  Future<ApiCallResponse> call({
    String? baseURL,
    String? authToken = '',
    String? email = '',
    String? callSid = '',
    String? callerId = '',
  }) async {
    baseURL ??= FFDevEnvironmentValues().baseUrl;
    final baseUrl = TwilioGroup.getBaseUrl(
      baseURL: baseURL,
      authToken: authToken,
    );

    final ffApiRequestBody = '''
    {
      "transferTo": "${email}",
      "transferCallSid": "${callSid}",
      "callerId": ${callerId},
      "isPepPatient": true,
      "key": "OUTGOING"
    }''';

    return ApiManager.instance.makeApiCall(
      callName: 'Call Transfer',
      apiUrl: 'https://sandbox.hbox.ai/twilio/transfer',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
        'ngrok-skip-browser-warning': 'true',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? success(dynamic response) => castToType<bool>(getJsonField(
    response,
    r'''$.success''',
  ));
}

/// End Twilio Group Code

class LoginAPICall {
  static Future<ApiCallResponse> call({
    String? email = '',
    String? password = '',
    String? baseUrl,
  }) async {
    baseUrl ??= FFDevEnvironmentValues().baseUrl;

    final ffApiRequestBody = '''
{
  "email": "${email}",
  "password": "${password}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'LoginAPI',
      apiUrl: '${baseUrl}/auth/signin',
      callType: ApiCallType.POST,
      headers: {
        'Content-type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? getToken(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.token''',
      ));
}

class GetProfileCall {
  static Future<ApiCallResponse> call({
    String? email = '',
    String? authToken = '',
    String? baseUrl,
  }) async {
    baseUrl ??= FFDevEnvironmentValues().baseUrl;

    return ApiManager.instance.makeApiCall(
      callName: 'GetProfile',
      apiUrl: '${baseUrl}/api/user/${email}/profile',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static int? profileID(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.profile.id''',
      ));
  static String? username(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.profile.fullName''',
      ));
  static String? usertype(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.profile.type''',
      ));
}

class GetHasuraTokenCall {
  static Future<ApiCallResponse> call({
    String? profileID = '',
    String? authToken = '',
    String? baseUrl,
  }) async {
    baseUrl ??= FFDevEnvironmentValues().baseUrl;

    return ApiManager.instance.makeApiCall(
      callName: 'GetHasuraToken',
      apiUrl: '${baseUrl}/api/user/${profileID}/hasuraToken',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? hasuraToken(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.token''',
      ));
}

class GQLgetClinicNamesCall {
  static Future<ApiCallResponse> call({
    String? hasuraToken = '',
    String? graphQLBaseURL,
  }) async {
    graphQLBaseURL ??= FFDevEnvironmentValues().graphQLBaseURL;

    final ffApiRequestBody = '''
{"query":"query MyQuery { pep_vw_available_clinics { clinic_id clinic_name patient_clinic_timezone } }"}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GQLgetClinicNames',
      apiUrl: '${graphQLBaseURL}/v1/graphql',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${hasuraToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? clinicDetailsMap(dynamic response) => getJsonField(
        response,
        r'''$.data.pep_vw_available_clinics''',
        true,
      ) as List?;
  static List<String>? clinicNames(dynamic response) => (getJsonField(
        response,
        r'''$.data.pep_vw_available_clinics[:].clinic_name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<int>? clinicIDs(dynamic response) => (getJsonField(
        response,
        r'''$.data.pep_vw_available_clinics[:].clinic_id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
}

class GQLgetProviderListCall {
  static Future<ApiCallResponse> call({
    String? hasuraToken = '',
    String? clinicID = '',
    String? graphQLBaseURL,
  }) async {
    graphQLBaseURL ??= FFDevEnvironmentValues().graphQLBaseURL;

    final ffApiRequestBody = '''
{
  "query": "query MyQuery(\$clinicName: String) { pep_vw_consolidated_data(where: {clinic_id: {_eq: ${clinicID}}}, distinct_on: provider_id) { provider_id provider_name } }"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GQLgetProviderList',
      apiUrl: '${graphQLBaseURL}/v1/graphql',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${hasuraToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? providerNames(dynamic response) => (getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data[:].provider_name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<int>? providerIDs(dynamic response) => (getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data[:].provider_id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static List? providerDetailsMap(dynamic response) => getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data''',
        true,
      ) as List?;
}

class GQLgetFacilityNamesCall {
  static Future<ApiCallResponse> call({
    String? hasuraToken = '',
    String? clinicID = '',
    String? graphQLBaseURL,
  }) async {
    graphQLBaseURL ??= FFDevEnvironmentValues().graphQLBaseURL;

    final ffApiRequestBody = '''
{
  "query": "query MyQuery(\$clinicName: String) { pep_vw_consolidated_data(where: {clinic_id: {_eq: ${clinicID}}}, distinct_on: facility_id) { facility_id facility_name } }"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GQLgetFacilityNames',
      apiUrl: '${graphQLBaseURL}/v1/graphql',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${hasuraToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? facilityList(dynamic response) => (getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data[:].facility_name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<int>? facilityIDs(dynamic response) => (getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data[:].facility_id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static List? facilityDetailsMap(dynamic response) => getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data''',
        true,
      ) as List?;
}

class GQLgetByFunctionCall {
  static Future<ApiCallResponse> call({
    String? hasuraToken = '',
    String? requestBody = '',
    String? graphQLBaseURL,
  }) async {
    graphQLBaseURL ??= FFDevEnvironmentValues().graphQLBaseURL;

    final ffApiRequestBody = '''
${requestBody}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GQLgetByFunction',
      apiUrl: '${graphQLBaseURL}/v1/graphql',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${hasuraToken}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? consolidatedData(dynamic response) => getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data''',
        true,
      ) as List?;
  static List<String>? primaryDxList(dynamic response) => (getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data[:].primary_dx''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? secondaryDxList(dynamic response) => (getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data[:].secondary_dx''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? primaryInsList(dynamic response) => (getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data[:].primary_insurance_provider''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? secondaryInsList(dynamic response) => (getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data[:].secondary_insurance_provider''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List? groupDetails(dynamic response) => getJsonField(
        response,
        r'''$.data.pep_vw_group_details''',
        true,
      ) as List?;
  static List? callDetails(dynamic response) => getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data[:].call_details''',
        true,
      ) as List?;
  static List<int>? filteredIDs(dynamic response) => (getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data[:].patient_clinic_data_id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static List<int>? patientsByGroupType(dynamic response) => (getJsonField(
        response,
        r'''$.data.pep_vw_group_type_filter[:].pep_patient_clinic_data_id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static String? scheduleTime(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.pep_vw_group_details[:].schedule_dt''',
      ));
  static int? currentPatient(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.pep_vw_patient_list[:].pep_patient_clinic_data_id''',
      ));
  static int? currentPatientGroupID(dynamic response) =>
      castToType<int>(getJsonField(
        response,
        r'''$.data.pep_vw_patient_list[:].group_id''',
      ));
  static List? assignedGroupList(dynamic response) => getJsonField(
        response,
        r'''$.data.pep_vw_patient_list''',
        true,
      ) as List?;
  static List? patientEnrollerList(dynamic response) => getJsonField(
        response,
        r'''$.data.pep_vw_patient_enroller_list''',
        true,
      ) as List?;
  static List? virtualEnrollmentSpecialist(dynamic response) => getJsonField(
        response,
        r'''$.data.pep_vw_enrollment_specialists''',
        true,
      ) as List?;
  static List? patientEnrollerCallDetails(dynamic response) => getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data[:].patient_enroller_call_details''',
        true,
      ) as List?;
  static List? careSpecialistCallDetails(dynamic response) => getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data[:].care_specialist_call_details''',
        true,
      ) as List?;
  static dynamic smsTemplates(dynamic response) => getJsonField(
        response,
        r'''$.data.pep_sms_template[:].sms_template''',
      );
  static List? insuranceType(dynamic response) => getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data[:].insurance_type''',
        true,
      ) as List?;
  static List<String>? facilityName(dynamic response) => (getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data[:].facility_name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List? rpmStatusUpdates(dynamic response) => getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data[:].rpm_status_updates''',
        true,
      ) as List?;
  static List? ccmStatusUpdates(dynamic response) => getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data[:].ccm_status_updates''',
        true,
      ) as List?;
  static List? careSpecialistList(dynamic response) => getJsonField(
        response,
        r'''$.data.pep_vw_care_specialist_patient_list''',
        true,
      ) as List?;
  static List? usernames(dynamic response) => getJsonField(
        response,
        r'''$.data.api_hboxuser''',
        true,
      ) as List?;
  static List<String>? smsTemplate(dynamic response) => (getJsonField(
        response,
        r'''$.data.pep_sms_template[:].sms_template''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static int? vpeDeferredPatientList(dynamic response) =>
      castToType<int>(getJsonField(
        response,
        r'''$.data.pep_vw_vpe_deferred_list[:].pep_patient_clinic_data_id''',
      ));
  static bool? taskAssigned(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.data.pep_task_assignment[:].is_deleted''',
      ));
  static String? timeZone(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.pep_vw_consolidated_data[:].patient_clinic_timezone''',
      ));
  static bool? deferredTaskAssigned(dynamic response) =>
      castToType<bool>(getJsonField(
        response,
        r'''$.data.pep_vw_enrollment_specialists[:].deferred_task''',
      ));
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}

