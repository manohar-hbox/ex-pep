// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TwilioCallDataStruct extends BaseStruct {
  TwilioCallDataStruct({
    String? toPhoneNumber,
    String? fromPhoneNumber,
    String? clinicId,
    String? patientId,
    String? callerId,
    String? originNumberType,
    String? patientFirstName,
    String? patientLastName,
    String? patientClinicTimeZone,
  })  : _toPhoneNumber = toPhoneNumber,
        _fromPhoneNumber = fromPhoneNumber,
        _clinicId = clinicId,
        _patientId = patientId,
        _callerId = callerId,
        _originNumberType = originNumberType,
        _patientFirstName = patientFirstName,
        _patientLastName = patientLastName,
        _patientClinicTimeZone = patientClinicTimeZone;

  String? _toPhoneNumber;
  String get toPhoneNumber => _toPhoneNumber ?? '';
  set toPhoneNumber(String? val) => _toPhoneNumber = val;

  bool hasToPhoneNumber() => _toPhoneNumber != null;

  String? _fromPhoneNumber;
  String get fromPhoneNumber => _fromPhoneNumber ?? '';
  set fromPhoneNumber(String? val) => _fromPhoneNumber = val;

  bool hasPhoneNumber() => _fromPhoneNumber != null;

  // "clinicId" field.
  String? _clinicId;
  String get clinicId => _clinicId ?? '';
  set clinicId(String? val) => _clinicId = val;

  bool hasClinicId() => _clinicId != null;

  // "patientId" field.
  String? _patientId;
  String get patientId => _patientId ?? '';
  set patientId(String? val) => _patientId = val;

  bool hasPatientId() => _patientId != null;

  // "callerId" field.
  String? _callerId;
  String get callerId => _callerId ?? '';
  set callerId(String? val) => _callerId = val;

  bool hasCallerId() => _callerId != null;

  // "originNumberType" field.
  String? _originNumberType;
  String get originNumberType => _originNumberType ?? '';
  set originNumberType(String? val) => _originNumberType = val;

  bool hasOriginNumberType() => _originNumberType != null;

  // "patientFirstName" field.
  String? _patientFirstName;
  String get patientFirstName => _patientFirstName ?? '';
  set patientFirstName(String? val) => _patientFirstName = val;

  bool hasPatientFirstName() => _patientFirstName != null;

  // "patientLastName" field.
  String? _patientLastName;
  String get patientLastName => _patientLastName ?? '';
  set patientLastName(String? val) => _patientLastName = val;

  bool hasPatientLastName() => _patientLastName != null;

  // "patientClinicTimeZone" field.
  String? _patientClinicTimeZone;
  String get patientClinicTimeZone => _patientClinicTimeZone ?? '';
  set patientClinicTimeZone(String? val) => _patientClinicTimeZone = val;

  bool hasPatientClinicTimeZone() => _patientClinicTimeZone != null;

  static TwilioCallDataStruct fromMap(Map<String, dynamic> data) =>
      TwilioCallDataStruct(
        toPhoneNumber: data['toPhoneNumber'] as String?,
        fromPhoneNumber: data['fromPhoneNumber'] as String?,
        clinicId: data['clinicId'] as String?,
        patientId: data['patientId'] as String?,
        callerId: data['callerId'] as String?,
        originNumberType: data['originNumberType'] as String?,
        patientFirstName: data['patientFirstName'] as String?,
        patientLastName: data['patientLastName'] as String?,
        patientClinicTimeZone: data['patientClinicTimeZone'] as String?,
      );

  static TwilioCallDataStruct? maybeFromMap(dynamic data) => data is Map
      ? TwilioCallDataStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'toPhoneNumber': _toPhoneNumber,
        'fromPhoneNumber': _fromPhoneNumber,
        'clinicId': _clinicId,
        'patientId': _patientId,
        'callerId': _callerId,
        'originNumberType': _originNumberType,
        'patientFirstName': _patientFirstName,
        'patientLastName': _patientLastName,
        'patientClinicTimeZone': _patientClinicTimeZone,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'toPhoneNumber': serializeParam(
          _toPhoneNumber,
          ParamType.String,
        ),
        'fromPhoneNumber': serializeParam(
          _fromPhoneNumber,
          ParamType.String,
        ),
        'clinicId': serializeParam(
          _clinicId,
          ParamType.String,
        ),
        'patientId': serializeParam(
          _patientId,
          ParamType.String,
        ),
        'callerId': serializeParam(
          _callerId,
          ParamType.String,
        ),
        'originNumberType': serializeParam(
          _originNumberType,
          ParamType.String,
        ),
        'patientFirstName': serializeParam(
          _patientFirstName,
          ParamType.String,
        ),
        'patientLastName': serializeParam(
          _patientLastName,
          ParamType.String,
        ),
        'patientClinicTimeZone': serializeParam(
          _patientClinicTimeZone,
          ParamType.String,
        ),
      }.withoutNulls;

  static TwilioCallDataStruct fromSerializableMap(Map<String, dynamic> data) =>
      TwilioCallDataStruct(
        toPhoneNumber: deserializeParam(
          data['toPhoneNumber'],
          ParamType.String,
          false,
        ),
        fromPhoneNumber: deserializeParam(
          data['fromPhoneNumber'],
          ParamType.String,
          false,
        ),
        clinicId: deserializeParam(
          data['clinicId'],
          ParamType.String,
          false,
        ),
        patientId: deserializeParam(
          data['patientId'],
          ParamType.String,
          false,
        ),
        callerId: deserializeParam(
          data['callerId'],
          ParamType.String,
          false,
        ),
        originNumberType: deserializeParam(
          data['originNumberType'],
          ParamType.String,
          false,
        ),
        patientFirstName: deserializeParam(
          data['patientFirstName'],
          ParamType.String,
          false,
        ),
        patientLastName: deserializeParam(
          data['patientLastName'],
          ParamType.String,
          false,
        ),
        patientClinicTimeZone: deserializeParam(
          data['patientClinicTimeZone'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'TwilioCallDataStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is TwilioCallDataStruct &&
        toPhoneNumber == other.toPhoneNumber &&
        fromPhoneNumber == other.fromPhoneNumber &&
        clinicId == other.clinicId &&
        patientId == other.patientId &&
        callerId == other.callerId &&
        originNumberType == other.originNumberType &&
        patientFirstName == other.patientFirstName &&
        patientLastName == other.patientLastName &&
        patientClinicTimeZone == other.patientClinicTimeZone;
  }

  @override
  int get hashCode => const ListEquality().hash([
        toPhoneNumber,
        fromPhoneNumber,
        clinicId,
        patientId,
        callerId,
        originNumberType,
        patientFirstName,
        patientLastName,
        patientClinicTimeZone
      ]);
}

TwilioCallDataStruct createTwilioCallDataStruct({
  String? toPhoneNumber,
  String? fromPhoneNumber,
  String? clinicId,
  String? patientId,
  String? callerId,
  String? originNumberType,
  String? patientFirstName,
  String? patientLastName,
  String? patientClinicTimeZone,
}) =>
    TwilioCallDataStruct(
      toPhoneNumber: toPhoneNumber,
      fromPhoneNumber: fromPhoneNumber,
      clinicId: clinicId,
      patientId: patientId,
      callerId: callerId,
      originNumberType: originNumberType,
      patientFirstName: patientFirstName,
      patientLastName: patientLastName,
      patientClinicTimeZone: patientClinicTimeZone,
    );
