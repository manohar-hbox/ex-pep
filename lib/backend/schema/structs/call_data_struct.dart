// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CallDataStruct extends BaseStruct {
  CallDataStruct({
    String? startTime,
    String? endTime,
    String? duration,
  })  : _startTime = startTime,
        _endTime = endTime,
        _duration = duration;

  // "startTime" field.
  String? _startTime;
  String get startTime => _startTime ?? '';
  set startTime(String? val) => _startTime = val;

  bool hasStartTime() => _startTime != null;

  // "endTime" field.
  String? _endTime;
  String get endTime => _endTime ?? '';
  set endTime(String? val) => _endTime = val;

  bool hasEndTime() => _endTime != null;

  // "duration" field.
  String? _duration;
  String get duration => _duration ?? '';
  set duration(String? val) => _duration = val;

  bool hasDuration() => _duration != null;

  static CallDataStruct fromMap(Map<String, dynamic> data) => CallDataStruct(
        startTime: data['startTime'] as String?,
        endTime: data['endTime'] as String?,
        duration: data['duration'] as String?,
      );

  static CallDataStruct? maybeFromMap(dynamic data) =>
      data is Map ? CallDataStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'startTime': _startTime,
        'endTime': _endTime,
        'duration': _duration,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'startTime': serializeParam(
          _startTime,
          ParamType.String,
        ),
        'endTime': serializeParam(
          _endTime,
          ParamType.String,
        ),
        'duration': serializeParam(
          _duration,
          ParamType.String,
        ),
      }.withoutNulls;

  static CallDataStruct fromSerializableMap(Map<String, dynamic> data) =>
      CallDataStruct(
        startTime: deserializeParam(
          data['startTime'],
          ParamType.String,
          false,
        ),
        endTime: deserializeParam(
          data['endTime'],
          ParamType.String,
          false,
        ),
        duration: deserializeParam(
          data['duration'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'CallDataStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is CallDataStruct &&
        startTime == other.startTime &&
        endTime == other.endTime &&
        duration == other.duration;
  }

  @override
  int get hashCode => const ListEquality().hash([startTime, endTime, duration]);
}

CallDataStruct createCallDataStruct({
  String? startTime,
  String? endTime,
  String? duration,
}) =>
    CallDataStruct(
      startTime: startTime,
      endTime: endTime,
      duration: duration,
    );
