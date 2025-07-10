import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/auth/custom_auth/auth_util.dart';

int nextPage(
    int pageOffest,
    int rowsPerPage,
    ) {
  return pageOffest + rowsPerPage;
}

List<dynamic>? filterPESListLocally(
    List<dynamic>? pesList,
    String? searchKey,
    String? searchValue,
    ) {
  if (pesList == null || searchKey == null || searchValue == null) {
    return null;
  }

  return pesList.where((patient) {
    final value = patient[searchKey];
    if (value is String) {
      return value.toLowerCase().contains(searchValue.toLowerCase());
    }
    return false;
  }).toList();
}

dynamic getCreateGroupPatientList(List<int> patientClinicDataIDs) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['patientClinicDataIDs'] = patientClinicDataIDs;

  request['query'] =
  "query MyQuery(\$patientClinicDataIDs: [Int!]) { pep_vw_consolidated_data(where: {patient_clinic_data_id: {_in: \$patientClinicDataIDs}}, order_by: {full_name: asc}) { patient_clinic_data_id full_name dob emr_id provider_name primary_dx secondary_dx } }";

  return json.encode(request);
}

List<dynamic>? filterAppointmentListLocally(
    List<dynamic>? appointmentList,
    List<String>? appointmentFacility,
    String? appointmentDate,
    ) {
  if (appointmentFacility != null && appointmentFacility.isNotEmpty) {
    appointmentList?.removeWhere(
            (item) => !appointmentFacility.contains(item['facility_name']));
  }

  if (appointmentDate != null && appointmentDate != '') {
    appointmentList
        ?.removeWhere((item) => item['appointment_date'] != appointmentDate);
  }

  return appointmentList;
}

dynamic getRPMStatusUpdates(int patientClinicDataID) {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_consolidated_data(where: {patient_clinic_data_id: {_eq: $patientClinicDataID}}) { rpm_status_updates patient_clinic_timezone } }"
  };

  return json.encode(request);
}

List<String> formatPhoneNumberList(List<String> phoneList) {
  return phoneList.map((phone) {
    if (phone.length == 10 && RegExp(r'^\d{10}$').hasMatch(phone)) {
      return '${phone.substring(0, 3)}-${phone.substring(3, 6)}-${phone.substring(6)}';
    } else {
      return phone; // Return original if invalid
    }
  }).toList();
}

dynamic getCCMStatusUpdates(int patientClinicDataID) {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_consolidated_data(where: {patient_clinic_data_id: {_eq: $patientClinicDataID}}) { ccm_status_updates patient_clinic_timezone } }"
  };
  print(request);

  return json.encode(request);
}

dynamic checkPESAssignedTasks(String pesId) {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_patient_enroller_list (where: {patient_enroller_id: {_eq: $pesId}}) { deferred_task follow_up patient_enroller_id } }"
  };

  return json.encode(request);
}

DateTime? datetimeStringToDate(String datetimeString) {
  // Parse the input date string to DateTime object
  DateTime? dateTime = DateTime.tryParse(datetimeString);

  if (dateTime != null) {
    // Convert to UTC and keep only year, month, and day
    DateTime utcDateTime =
    DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
    return utcDateTime;
  }
  return null;
}

dynamic checkCSAssignedTasks(String csId) {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_care_specialist_list (where: {care_specialist_id: {_eq: $csId}}) { deferred_task follow_up care_specialist_id } }"
  };

  return json.encode(request);
}

List<String> getFacilityNames(
    List<dynamic> facilityDetailsMap,
    List<int>? facilityIDs,
    ) {
  if (facilityIDs == null) {
    return <String>[];
  }

  List<String> facilityNames = [];

  for (var facility in facilityDetailsMap) {
    if (facilityIDs.contains(facility['facility_id'])) {
      facilityNames.add(facility['facility_name']);
    }
  }

  return facilityNames;
}

List<String> returnStringList(List<dynamic>? inputList) {
  // accept a dynamic list and return an int list
  List<String> outputList = [];
  if (inputList != null) {
    for (dynamic item in inputList) {
      outputList.add(item);
    }
  }
  return outputList;
}

String returnString(dynamic input) {
  if (input == null) {
    return '';
  } else {
    return input.toString();
  }
}

int returnInt(dynamic input) {
  if (input == null) {
    return -1;
  } else {
    return input.toInt();
  }
}

List<String> getProviderNames(
    List<dynamic> providerDetailsMap,
    List<int>? providerIDs,
    ) {
  if (providerIDs == null) {
    return <String>[];
  }

  List<String> providerNames = [];

  for (var provider in providerDetailsMap) {
    if (providerIDs.contains(provider['provider_id'])) {
      providerNames.add(provider['provider_name']);
    }
  }

  return providerNames;
}

dynamic getPESUpdateClinics(
    List<dynamic> clinicList,
    List<int> clinics,
    ) {
  List<dynamic> availableClinics = [];
  for (var clinic in clinicList) {
    if (clinics.contains(clinic['clinic_id']) ||
        clinic['has_active_enroller'] == false) {
      availableClinics.add(clinic);
    }
  }
  return {'pep_vw_available_clinics': availableClinics};
}

dynamic generateClinicAppointmentsList(int? clinicID) {
  dynamic request = "";
  if (clinicID != null) {
    request = {"operationName": "MyQuery", "variables": {}};
    request['variables']['clinicID'] = clinicID;
    request['query'] =
    "query MyQuery(\$clinicID: Int!) { pep_vw2_clinic_appointments(where: {clinic_id: {_eq: \$clinicID}}) { appointment_id clinic_name facility_name appointment_date appointment_start_time appointment_end_time patient_clinic_data_id } }";
  } else {
    request = {"operationName": "MyQuery"};
    request['query'] =
    "query MyQuery { pep_vw2_clinic_appointments { appointment_id clinic_name facility_name appointment_date appointment_start_time appointment_end_time patient_clinic_data_id } }";
  }

  return json.encode(request);
}

dynamic autofillSearchForPES(String searchStr) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['searchStr'] = ".*" + searchStr + ".*";

  request['query'] =
  "query MyQuery(\$searchStr: String!) { pep_vw_patient_enroller_patient_list(where: {search_string: {_iregex: \$searchStr}}) { search_string } }";

  return json.encode(request);
}

dynamic generateSecondaryInsListRequest(
    int clinicID,
    List<int>? providerIDs,
    List<String>? primaryList,
    List<String>? secondaryList,
    List<String>? primaryInsList,
    List<int>? facilityIDs,
    ) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['clinicID'] = clinicID;

  String query_sub_string_1 = "\$clinicID: Int!,";
  String query_sub_string_2 =
      "ccm_status: {_nin: [1,2,3,7,8,9,10]}, clinic_id: {_eq: \$clinicID},";
  if (facilityIDs != null) {
    if (facilityIDs.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$facilityIDs: [Int!],";
      query_sub_string_2 =
          query_sub_string_2 + "facility_id: {_in: \$facilityIDs},";
      request['variables']['facilityIDs'] = facilityIDs;
    }
  }
  if (providerIDs != null) {
    if (providerIDs.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$providerIDs: [Int!],";
      query_sub_string_2 =
          query_sub_string_2 + "provider_id: {_in: \$providerIDs},";
      request['variables']['providerIDs'] = providerIDs;
    }
  }
  if (primaryList != null) {
    if (primaryList.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$primaryList: [String!],";
      query_sub_string_2 =
          query_sub_string_2 + "primary_dx: {_in: \$primaryList},";
      request['variables']['primaryList'] = primaryList;
    }
  }
  if (secondaryList != null) {
    if (secondaryList.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$secondaryList: [String!],";
      query_sub_string_2 =
          query_sub_string_2 + "secondary_dx: {_in: \$secondaryList},";
      request['variables']['secondaryList'] = secondaryList;
    }
  }
  if (primaryInsList != null) {
    if (primaryInsList.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$primaryInsList: [String!],";
      query_sub_string_2 = query_sub_string_2 +
          "primary_insurance_provider: {_in: \$primaryInsList},";
      request['variables']['primaryInsList'] = primaryInsList;
    }
  }

  // to remove the trailing commas
  query_sub_string_1 =
      query_sub_string_1.substring(0, query_sub_string_1.length - 1);
  query_sub_string_2 =
      query_sub_string_2.substring(0, query_sub_string_2.length - 1);

  request['query'] =
  "query MyQuery(${query_sub_string_1}) { pep_vw_consolidated_data(where: {${query_sub_string_2}}, distinct_on: secondary_insurance_provider) { secondary_insurance_provider } }";

  return json.encode(request);
}

dynamic getPatientEnrollerClinics(int csID) {
  dynamic request = {
    "query":
    "query MyQuery { pep_patient_enroller_active_assignments(where: {patient_enroller_id: {_eq: $csID}}) { clinic_ids } }"
  };

  return json.encode(request);
}

dynamic generateUpdateUserBody(
    String firstname,
    String lastname,
    String email,
    String password,
    List<int>? clinicids,
    bool taskAssigned,
    bool followUpTask,
    ) {
  dynamic request = {};
  request['first_name'] = firstname;
  request['last_name'] = lastname;
  request['email'] = email;
  if (password != '') {
    request['password'] = password;
  }
  request['deferred_task'] = taskAssigned;
  request['follow_up_task'] = followUpTask;
  if (clinicids == null) {
    request['clinic_ids'] = [];
  } else {
    clinicids.remove(-1);
    request['clinic_ids'] = clinicids;
  }
  return json.encode(request);
}

dynamic generateClinicAppointmentsFacility(int clinicID) {
  dynamic request = "";
  request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['clinicID'] = clinicID;
  request['query'] =
  "query MyQuery(\$clinicID: Int!) { pep_vw2_clinic_appointments(where: {clinic_id: {_eq: \$clinicID}}, distinct_on: facility_name) { facility_name } }";

  return json.encode(request);
}

dynamic getPatientEnrollerPatientList(List<int> clinicID) {
  dynamic request = {
    "query":
    "query MyQuery {pep_vw_patient_enroller_patient_list(where: {clinic_id: {_in: $clinicID}}) { pep_patient_id patient_clinic_data_id full_name dob clinic_id clinic_name provider_name patient_clinic_timezone phone_number consented_appointment_date_time ccm_status_value rpm_status_value }}"
  };

  return json.encode(request);
}

dynamic getSuggestedVitals(List<int> causeIDS) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['causeIDS'] = causeIDS;

  request['query'] =
  "query MyQuery(\$causeIDS: [Int!]) { api_prescriptioncauselist(where: {id: {_in: \$causeIDS}}) { suggested_vitals } }";

  return json.encode(request);
}

dynamic autofillSearchForCS(String searchStr) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['searchStr'] = ".*" + searchStr + ".*";

  request['query'] =
  "query MyQuery(\$searchStr: String!) { pep_vw_care_specialist_patient_list(where: {search_string: {_iregex: \$searchStr}}) { search_string } }";

  return json.encode(request);
}

dynamic getGroupPatientList(int groupID) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['groupID'] = groupID;

  request['query'] =
  "query MyQuery(\$groupID: Int!) { pep_vw_group_patient_list(where: {group_id: {_eq: \$groupID}}) { assigned_clinic_id patient_list } }";

  return json.encode(request);
}

dynamic searchForCSPatientID(String searchStr) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['searchStr'] = searchStr;

  request['query'] =
  "query MyQuery(\$searchStr: String!) { pep_vw_care_specialist_patient_list(where: {search_string: {_eq: \$searchStr}}) { patient_clinic_data_id clinic_id } }";

  return json.encode(request);
}

dynamic autofillSearchPPCID(
    int clinicID,
    String searchStr,
    ) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['clinicID'] = clinicID;
  request['variables']['searchStr'] = searchStr;

  request['query'] =
  "query MyQuery(\$clinicID: Int!, \$searchStr: String!) { pep_vw_consolidated_data(where: {ccm_status: {_nin: [1,2,3,7,8,9,10]}, clinic_id: {_eq: \$clinicID}, search_string: {_eq: \$searchStr}}) { patient_clinic_data_id } }";

  return json.encode(request);
}

dynamic generateSecondaryListRequest(
    int clinicID,
    List<int>? providerIDs,
    List<String>? primaryList,
    List<int>? facilityIDs,
    ) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['clinicID'] = clinicID;

  String query_sub_string_1 = "\$clinicID: Int!,";
  String query_sub_string_2 =
      "ccm_status: {_nin: [1,2,3,7,8,9,10]}, clinic_id: {_eq: \$clinicID},";
  if (facilityIDs != null) {
    if (facilityIDs.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$facilityIDs: [Int!],";
      query_sub_string_2 =
          query_sub_string_2 + "facility_id: {_in: \$facilityIDs},";
      request['variables']['facilityIDs'] = facilityIDs;
    }
  }
  if (providerIDs != null) {
    if (providerIDs.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$providerIDs: [Int!],";
      query_sub_string_2 =
          query_sub_string_2 + "provider_id: {_in: \$providerIDs},";
      request['variables']['providerIDs'] = providerIDs;
    }
  }
  if (primaryList != null) {
    if (primaryList.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$primaryList: [String!],";
      query_sub_string_2 =
          query_sub_string_2 + "primary_dx: {_in: \$primaryList},";
      request['variables']['primaryList'] = primaryList;
    }
  }

  // to remove the trailing commas
  query_sub_string_1 =
      query_sub_string_1.substring(0, query_sub_string_1.length - 1);
  query_sub_string_2 =
      query_sub_string_2.substring(0, query_sub_string_2.length - 1);

  request['query'] =
  "query MyQuery(${query_sub_string_1}) { pep_vw_consolidated_data(where: {${query_sub_string_2}}, distinct_on: secondary_dx) { secondary_dx } }";

  return json.encode(request);
}

DateTime dtReturnFormatter(
    String datetime,
    String timezone,
    ) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final DateTime parsedDateTime = formatter.parse(datetime);

  final marchSecondSunday = DateTime(parsedDateTime.year, DateTime.march, 1)
      .subtract(Duration(
      days: DateTime(parsedDateTime.year, DateTime.march, 1).weekday))
      .add(Duration(days: 14));
  final novemberFirstSunday = DateTime(
      parsedDateTime.year, DateTime.november, 1)
      .subtract(Duration(
      days: DateTime(parsedDateTime.year, DateTime.november, 1).weekday))
      .add(Duration(days: 7));
  final startDaylightSaving = marchSecondSunday.add(Duration(hours: 2));
  final endDaylightSaving = novemberFirstSunday.add(Duration(hours: 2));

  final isDaylightSaving = parsedDateTime.isAfter(startDaylightSaving) &&
      parsedDateTime.isBefore(endDaylightSaving);

  switch (timezone) {
    case 'America/Phoenix':
      return parsedDateTime.subtract(Duration(hours: 7));
    case 'US/Central':
      if (isDaylightSaving) {
        return parsedDateTime.subtract(Duration(hours: 5));
      } else {
        return parsedDateTime.subtract(Duration(hours: 6));
      }
    case 'US/Eastern':
      if (isDaylightSaving) {
        return parsedDateTime.subtract(Duration(hours: 4));
      } else {
        return parsedDateTime.subtract(Duration(hours: 5));
      }
    case 'US/Mountain':
      if (isDaylightSaving) {
        return parsedDateTime.subtract(Duration(hours: 6));
      } else {
        return parsedDateTime.subtract(Duration(hours: 7));
      }
    case 'US/Pacific':
      if (isDaylightSaving) {
        return parsedDateTime.subtract(Duration(hours: 7));
      } else {
        return parsedDateTime.subtract(Duration(hours: 8));
      }
    case 'LOCAL':
      final utcDT =
      DateFormat('yyyy-MM-dd HH:mm:ss').parse(datetime, true).toUtc();
      final localDT = utcDT.toLocal();
      return localDT;
    default:
      return parsedDateTime;
  }
}

String dtFormatterNew(
    DateTime? datetime,
    String timezone,
    ) {
  if (datetime == null) {
    return '';
  }

  final marchSecondSunday = DateTime(datetime.year, DateTime.march, 1)
      .subtract(
      Duration(days: DateTime(datetime.year, DateTime.march, 1).weekday))
      .add(Duration(days: 14));
  final novemberFirstSunday = DateTime(datetime.year, DateTime.november, 1)
      .subtract(
      Duration(days: DateTime(datetime.year, DateTime.november, 1).weekday))
      .add(Duration(days: 7));
  final startDaylightSaving = marchSecondSunday.add(Duration(hours: 2));
  final endDaylightSaving = novemberFirstSunday.add(Duration(hours: 2));

  final isDaylightSaving = datetime.isAfter(startDaylightSaving) &&
      datetime.isBefore(endDaylightSaving);

  String dt = datetime.toIso8601String();

  switch (timezone) {
    case 'America/Phoenix':
      return '$dt-07:00';
    case 'US/Central':
      if (isDaylightSaving) {
        return '$dt-05:00';
      } else {
        return '$dt-06:00';
      }
    case 'US/Eastern':
      if (isDaylightSaving) {
        return '$dt-04:00';
      } else {
        return '$dt-05:00';
      }
    case 'US/Mountain':
      if (isDaylightSaving) {
        return '$dt-06:00';
      } else {
        return '$dt-07:00';
      }
    case 'US/Pacific':
      if (isDaylightSaving) {
        return '$dt-07:00';
      } else {
        return '$dt-08:00';
      }
    default:
      return '$dt+Z';
  }
}

dynamic getAppointmentTimes(
    int facilityID,
    String appointmentDate,
    ) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['appointmentDate'] = appointmentDate;

  request['query'] =
  "query MyQuery(\$appointmentDate: date!) { pep_vw_available_clinic_appointments(where: {facility_id: {_eq: $facilityID}, _and: {appointment_date: {_eq: \$appointmentDate}}}) { appointment_hour fmt_appointment_hour } }";

  return json.encode(request);
}

dynamic generateInsTypeListRequest(
    int clinicID,
    List<int>? providerIDs,
    List<String>? primaryList,
    List<String>? secondaryList,
    List<String>? primaryInsList,
    List<String>? secondaryInsList,
    List<int>? facilityIDs,
    ) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['clinicID'] = clinicID;

  String query_sub_string_1 = "\$clinicID: Int!,";
  String query_sub_string_2 =
      "ccm_status: {_nin: [1,2,3,7,8,9,10]}, clinic_id: {_eq: \$clinicID},";
  if (facilityIDs != null) {
    if (facilityIDs.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$facilityIDs: [Int!],";
      query_sub_string_2 =
          query_sub_string_2 + "facility_id: {_in: \$facilityIDs},";
      request['variables']['facilityIDs'] = facilityIDs;
    }
  }
  if (providerIDs != null) {
    if (providerIDs.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$providerIDs: [Int!],";
      query_sub_string_2 =
          query_sub_string_2 + "provider_id: {_in: \$providerIDs},";
      request['variables']['providerIDs'] = providerIDs;
    }
  }
  if (primaryList != null) {
    if (primaryList.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$primaryList: [String!],";
      query_sub_string_2 =
          query_sub_string_2 + "primary_dx: {_in: \$primaryList},";
      request['variables']['primaryList'] = primaryList;
    }
  }
  if (secondaryList != null) {
    if (secondaryList.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$secondaryList: [String!],";
      query_sub_string_2 =
          query_sub_string_2 + "secondary_dx: {_in: \$secondaryList},";
      request['variables']['secondaryList'] = secondaryList;
    }
  }
  if (primaryInsList != null) {
    if (primaryInsList.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$primaryInsList: [String!],";
      query_sub_string_2 = query_sub_string_2 +
          "primary_insurance_provider: {_in: \$primaryInsList},";
      request['variables']['primaryInsList'] = primaryInsList;
    }
  }
  if (secondaryInsList != null) {
    if (secondaryInsList.isNotEmpty) {
      query_sub_string_1 =
          query_sub_string_1 + "\$secondaryInsList: [String!],";
      query_sub_string_2 = query_sub_string_2 +
          "secondary_insurance_provider: {_in: \$secondaryInsList},";
      request['variables']['secondaryInsList'] = secondaryInsList;
    }
  }

  // to remove the trailing commas
  query_sub_string_1 =
      query_sub_string_1.substring(0, query_sub_string_1.length - 1);
  query_sub_string_2 =
      query_sub_string_2.substring(0, query_sub_string_2.length - 1);

  request['query'] =
  "query MyQuery(${query_sub_string_1}) { pep_vw_consolidated_data(where: {${query_sub_string_2}}, distinct_on: insurance_type) { insurance_type } }";

  return json.encode(request);
}

String dtDisplayFormatterNew(
    String datetime,
    String timezone,
    ) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final DateTime parsedDateTime = formatter.parse(datetime);

  final marchSecondSunday = DateTime(parsedDateTime.year, DateTime.march, 1)
      .subtract(Duration(
      days: DateTime(parsedDateTime.year, DateTime.march, 1).weekday))
      .add(Duration(days: 14));
  final novemberFirstSunday = DateTime(
      parsedDateTime.year, DateTime.november, 1)
      .subtract(Duration(
      days: DateTime(parsedDateTime.year, DateTime.november, 1).weekday))
      .add(Duration(days: 7));
  final startDaylightSaving = marchSecondSunday.add(Duration(hours: 2));
  final endDaylightSaving = novemberFirstSunday.add(Duration(hours: 2));

  final isDaylightSaving = parsedDateTime.isAfter(startDaylightSaving) &&
      parsedDateTime.isBefore(endDaylightSaving);

  switch (timezone) {
    case 'America/Phoenix':
      return formatter.format(parsedDateTime.subtract(Duration(hours: 7)));
    case 'US/Central':
      if (isDaylightSaving) {
        return formatter.format(parsedDateTime.subtract(Duration(hours: 5)));
      } else {
        return formatter.format(parsedDateTime.subtract(Duration(hours: 6)));
      }
    case 'US/Eastern':
      if (isDaylightSaving) {
        return formatter.format(parsedDateTime.subtract(Duration(hours: 4)));
      } else {
        return formatter.format(parsedDateTime.subtract(Duration(hours: 5)));
      }
    case 'US/Mountain':
      if (isDaylightSaving) {
        return formatter.format(parsedDateTime.subtract(Duration(hours: 6)));
      } else {
        return formatter.format(parsedDateTime.subtract(Duration(hours: 7)));
      }
    case 'US/Pacific':
      if (isDaylightSaving) {
        return formatter.format(parsedDateTime.subtract(Duration(hours: 7)));
      } else {
        return formatter.format(parsedDateTime.subtract(Duration(hours: 8)));
      }
    default:
      return formatter.format(parsedDateTime);
  }
}

dynamic getNextPatient(int enrollmentSpecialistID) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['enrollmentSpecialistID'] = enrollmentSpecialistID;

  request['query'] =
  "query MyQuery(\$enrollmentSpecialistID: Int!) { pep_vw_patient_list(where: {enrollment_specialist_id: {_eq: \$enrollmentSpecialistID}}, limit: 1) { pep_patient_clinic_data_id group_id } }";

  return json.encode(request);
}

int generateFilteredPatientsListCount(List<int> filteredPatientsList) {
  return filteredPatientsList.length;
}

dynamic generatePrimaryInsListRequest(
    int clinicID,
    List<int>? providerIDs,
    List<String>? primaryList,
    List<String>? secondaryList,
    List<int>? facilityIDs,
    ) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['clinicID'] = clinicID;

  String query_sub_string_1 = "\$clinicID: Int!,";
  String query_sub_string_2 =
      "ccm_status: {_nin: [1,2,3,7,8,9,10]}, clinic_id: {_eq: \$clinicID},";
  if (facilityIDs != null) {
    if (facilityIDs.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$facilityIDs: [Int!],";
      query_sub_string_2 =
          query_sub_string_2 + "facility_id: {_in: \$facilityIDs},";
      request['variables']['facilityIDs'] = facilityIDs;
    }
  }
  if (providerIDs != null) {
    if (providerIDs.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$providerIDs: [Int!],";
      query_sub_string_2 =
          query_sub_string_2 + "provider_id: {_in: \$providerIDs},";
      request['variables']['providerIDs'] = providerIDs;
    }
  }
  if (primaryList != null) {
    if (primaryList.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$primaryList: [String!],";
      query_sub_string_2 =
          query_sub_string_2 + "primary_dx: {_in: \$primaryList},";
      request['variables']['primaryList'] = primaryList;
    }
  }
  if (secondaryList != null) {
    if (secondaryList.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$secondaryList: [String!],";
      query_sub_string_2 =
          query_sub_string_2 + "secondary_dx: {_in: \$secondaryList},";
      request['variables']['secondaryList'] = secondaryList;
    }
  }

  // to remove the trailing commas
  query_sub_string_1 =
      query_sub_string_1.substring(0, query_sub_string_1.length - 1);
  query_sub_string_2 =
      query_sub_string_2.substring(0, query_sub_string_2.length - 1);

  request['query'] =
  "query MyQuery(${query_sub_string_1}) { pep_vw_consolidated_data(where: {${query_sub_string_2}}, distinct_on: primary_insurance_provider) { primary_insurance_provider } }";

  return json.encode(request);
}

dynamic generatePrimaryListRequest(
    int clinicID,
    List<int>? providerIDs,
    List<int>? facilityIDs,
    ) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['clinicID'] = clinicID;

  String query_sub_string_1 = "\$clinicID: Int!,";
  String query_sub_string_2 =
      "ccm_status: {_nin: [1,2,3,7,8,9,10]}, clinic_id: {_eq: \$clinicID},";
  if (facilityIDs != null) {
    if (facilityIDs.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$facilityIDs: [Int!],";
      query_sub_string_2 =
          query_sub_string_2 + "facility_id: {_in: \$facilityIDs},";
      request['variables']['facilityIDs'] = facilityIDs;
    }
  }
  if (providerIDs != null) {
    if (providerIDs.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$providerIDs: [Int!],";
      query_sub_string_2 =
          query_sub_string_2 + "provider_id: {_in: \$providerIDs},";
      request['variables']['providerIDs'] = providerIDs;
    }
  }

  // to remove the trailing commas
  query_sub_string_1 =
      query_sub_string_1.substring(0, query_sub_string_1.length - 1);
  query_sub_string_2 =
      query_sub_string_2.substring(0, query_sub_string_2.length - 1);

  request['query'] =
  "query MyQuery(${query_sub_string_1}) { pep_vw_consolidated_data(where: {${query_sub_string_2}}, distinct_on: primary_dx) { primary_dx } }";

  return json.encode(request);
}

dynamic generateFilteredPatients(
    int clinicID,
    List<int>? providerIDs,
    List<String>? primaryList,
    List<String>? secondaryList,
    List<String>? programEligibility,
    List<String>? primaryInsList,
    List<String>? secondaryInsList,
    List<int>? facilityIDs,
    List<String>? insuranceType,
    String? zipcodes,
    DateTime? lastVisitedDate,
    ) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['clinicID'] = clinicID;

  String query_sub_string_1 = "\$clinicID: Int!,";
  String query_sub_string_2 =
      "ccm_status: {_nin: [1,2,3,7,8,9,10]}, clinic_id: {_eq: \$clinicID},";
  if (facilityIDs != null) {
    if (facilityIDs.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$facilityIDs: [Int!],";
      query_sub_string_2 =
          query_sub_string_2 + "facility_id: {_in: \$facilityIDs},";
      request['variables']['facilityIDs'] = facilityIDs;
    }
  }
  if (providerIDs != null) {
    if (providerIDs.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$providerIDs: [Int!],";
      query_sub_string_2 =
          query_sub_string_2 + "provider_id: {_in: \$providerIDs},";
      request['variables']['providerIDs'] = providerIDs;
    }
  }
  if (primaryList != null) {
    if (primaryList.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$primaryList: [String!],";
      query_sub_string_2 =
          query_sub_string_2 + "primary_dx: {_in: \$primaryList},";
      request['variables']['primaryList'] = primaryList;
    }
  }
  if (secondaryList != null) {
    if (secondaryList.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$secondaryList: [String!],";
      query_sub_string_2 =
          query_sub_string_2 + "secondary_dx: {_in: \$secondaryList},";
      request['variables']['secondaryList'] = secondaryList;
    }
  }
  if (programEligibility != null) {
    if (programEligibility.isNotEmpty) {
      if (programEligibility.contains("PCM")) {
        query_sub_string_2 = query_sub_string_2 + "pcm_flag: {_eq: true},";
      }
      if (programEligibility.contains("CCM")) {
        query_sub_string_2 = query_sub_string_2 + "ccm_flag: {_eq: true},";
      }
      if (programEligibility.contains("RPM")) {
        query_sub_string_2 = query_sub_string_2 + "rpm_flag: {_eq: true},";
      }
    }
  }
  /*
  if (latestCallStatus.isNotEmpty) {
    if (latestCallStatus.contains("Consented")) {
      query_sub_string_2 = query_sub_string_2 + "latest_call_status: {_eq: 1},";
    }
    if (latestCallStatus.contains("Rejected")) {
      query_sub_string_2 = query_sub_string_2 + "latest_call_status: {_eq: 2},";
    }
    if (latestCallStatus.contains("Escalate")) {
      query_sub_string_2 = query_sub_string_2 + "latest_call_status: {_eq: 3},";
    }
    if (latestCallStatus.contains("Deferred")) {
      query_sub_string_2 = query_sub_string_2 + "latest_call_status: {_eq: 4},";
    }
    if (latestCallStatus.contains("Didn't Pick Up")) {
      query_sub_string_2 = query_sub_string_2 + "latest_call_status: {_eq: 5},";
    }
  }
  */
  if (primaryInsList != null) {
    if (primaryInsList.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$primaryInsList: [String!],";
      query_sub_string_2 = query_sub_string_2 +
          "primary_insurance_provider: {_in: \$primaryInsList},";
      request['variables']['primaryInsList'] = primaryInsList;
    }
  }
  if (secondaryInsList != null) {
    if (secondaryInsList.isNotEmpty) {
      query_sub_string_1 =
          query_sub_string_1 + "\$secondaryInsList: [String!],";
      query_sub_string_2 = query_sub_string_2 +
          "secondary_insurance_provider: {_in: \$secondaryInsList},";
      request['variables']['secondaryInsList'] = secondaryInsList;
    }
  }
  if (insuranceType != null) {
    if (insuranceType.isNotEmpty) {
      query_sub_string_1 = query_sub_string_1 + "\$insuranceType: [String!],";
      query_sub_string_2 =
          query_sub_string_2 + "insurance_type: {_in: \$insuranceType},";
      request['variables']['insuranceType'] = insuranceType;
    }
  }
  if (zipcodes != null) {
    zipcodes = zipcodes.replaceAll(' ', '');
    List<String> zipList = zipcodes.split(',');
    if (zipList.isNotEmpty && zipList.first != "") {
      query_sub_string_1 = query_sub_string_1 + "\$zipList: [String!],";
      query_sub_string_2 = query_sub_string_2 + "zip_code: {_in: \$zipList},";
      request['variables']['zipList'] = zipList;
    }
  }
  if (lastVisitedDate != null) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(lastVisitedDate);
    query_sub_string_1 = query_sub_string_1 + "\$formattedDate: date!,";
    query_sub_string_2 =
        query_sub_string_2 + "last_seen_date: {_gt: \$formattedDate},";
    request['variables']['formattedDate'] = formattedDate;
  }
  // to remove the trailing commas
  query_sub_string_1 =
      query_sub_string_1.substring(0, query_sub_string_1.length - 1);
  query_sub_string_2 =
      query_sub_string_2.substring(0, query_sub_string_2.length - 1);

  request['query'] =
  "query MyQuery(${query_sub_string_1}) { pep_vw_consolidated_data(where: {${query_sub_string_2}}) { patient_clinic_data_id has_active_group } }";

  return json.encode(request);
}

int prevPage(
    int pageOffest,
    int rowsPerPage,
    ) {
  if (pageOffest == 0) {
    return pageOffest;
  } else {
    return pageOffest - rowsPerPage;
  }
}

String pageView(
    int pageOffset,
    int rowsPerPage,
    ) {
  String return_value = "${pageOffset} - ${pageOffset + rowsPerPage}";
  return return_value;
}

dynamic getCareSpecialistPatientList(List<int> clinicID) {
  dynamic request = {
    "query":
    "query MyQuery {pep_vw_care_specialist_patient_list(where: {clinic_id: {_in: $clinicID}},order_by: {consented_appointment_date_time: desc_nulls_last}) { pep_patient_id patient_clinic_data_id full_name clinic_id clinic_name patient_clinic_timezone consented_appointment_date_time dob provider_name mobile_phone_number ccm_status_value rpm_status_value }}"
  };

  return json.encode(request);
}

dynamic getPatientDetails(int patientClinicDataID) {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_consolidated_data(where: {patient_clinic_data_id: {_eq: $patientClinicDataID}}) { first_name last_name dob gender mobile_phone_number home_phone_number email address_line_1 city state state_id zip_code clinic_name facility_id facility_name emr_id provider_id provider_name primary_dx primary_dx_id secondary_dx secondary_dx_id primary_insurance_provider primary_insurance_id secondary_insurance_provider secondary_insurance_id rpm_flag ccm_flag pcm_flag pep_patient_id patient_clinic_timezone ccm_status rpm_status ccm_appointment_dt rpm_appointment_dt ccm_vitals clinic_id} }"
  };

  return json.encode(request);
}

dynamic getPatientsByGroupType(
    int clinicID,
    List<String> grouptype,
    ) {
  List<int> intList = grouptype.map((str) => int.parse(str)).toList();

  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['clinicID'] = clinicID;

  String query_sub_string_1 = "\$clinicID: Int!";
  String query_sub_string_2 =
      "clinic_id: {_eq: \$clinicID}, group_type: {_in: $intList}";

  request['query'] =
  "query MyQuery(${query_sub_string_1}) { pep_vw_group_type_filter(where: {${query_sub_string_2}}) { pep_patient_clinic_data_id } }";

  return json.encode(request);
}

dynamic getGSPatientList(String searchString) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['searchStr'] = ".*" + searchString + ".*";

  request['query'] =
  "query MyQuery(\$searchStr: String!) { pep_vw_consolidated_data(where: {search_string: {_iregex: \$searchStr}}, limit: 100) { pep_patient_id patient_clinic_data_id full_name dob home_phone_number mobile_phone_number email clinic_id clinic_name emr_id dob provider_name mobile_phone_number } }";

  return json.encode(request);
}

dynamic getIfClinicCanMakeOutgoingCall(
    int clinicId,
    int stateId,
    ) {
  dynamic request = {"operationName": "getClinicNumber", "variables": {}};
  request['variables']['clinicId'] = clinicId;
  request['variables']['stateId'] = stateId;

  request['query'] =
  // "query getClinicNumber(\$clinicId: Int) { api_origin_number_master(where: {is_deleted: {_eq: false}, is_active: {_eq: true}, clinic_mapped: {clinic_id: {_eq: \$clinicId}, is_deleted: {_eq: false}}, origin_number_type_id: {_eq: 1}}) { is_active is_global number_source_id phone_number origin_number_type_id } }";
  "query getClinicNumber(\$clinicId: Int, \$stateId: Int) { api_origin_number_master( where: { is_deleted: { _eq: false }, is_active: { _eq: true }, clinic_mapped: { _or: [ { clinic_id: { _eq: \$clinicId }, is_deleted: { _eq: false } }, { state_id: { _eq: \$stateId }, is_deleted: { _eq: false } } ] }, origin_number_type_id: { _eq: 1 } } ) { is_active is_global number_source_id phone_number origin_number_type_id clinic_mapped { clinic_id state_id } } }";

  return json.encode(request);
}

dynamic getCallDetailsCS(int patientClinicDataID) {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_consolidated_data(where: {patient_clinic_data_id: {_eq: $patientClinicDataID}}) { care_specialist_call_details } }"
  };

  return json.encode(request);
}

dynamic getCallDetailsPES(int patientClinicDataID) {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_consolidated_data(where: {patient_clinic_data_id: {_eq: $patientClinicDataID}}) { patient_enroller_call_details } }"
  };

  return json.encode(request);
}

dynamic generateTableDataRequest(
    String clinicName,
    List<String> providerList,
    List<String> primaryList,
    List<String> secondaryList,
    int pageOffset,
    List<String> programEligibility,
    List<String> primaryInsList,
    List<String> secondaryInsList,
    int rowsPerPage,
    ) {
  int rpp = rowsPerPage;
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['clinicName'] = clinicName;

  String query_sub_string_1 = "\$clinicName: String!,";
  String query_sub_string_2 =
      "latest_call_status: {_nin: [1, 2, 7]}, clinic_name: {_eq: \$clinicName},";

  if (providerList.isNotEmpty) {
    query_sub_string_1 = query_sub_string_1 + "\$providerList: [String!],";
    query_sub_string_2 =
        query_sub_string_2 + "provider_name: {_in: \$providerList},";
    request['variables']['providerList'] = providerList;
  }
  if (primaryList.isNotEmpty) {
    query_sub_string_1 = query_sub_string_1 + "\$primaryList: [String!],";
    query_sub_string_2 =
        query_sub_string_2 + "primary_dx: {_in: \$primaryList},";
    request['variables']['primaryList'] = primaryList;
  }
  if (secondaryList.isNotEmpty) {
    query_sub_string_1 = query_sub_string_1 + "\$secondaryList: [String!],";
    query_sub_string_2 =
        query_sub_string_2 + "secondary_dx: {_in: \$secondaryList},";
    request['variables']['secondaryList'] = secondaryList;
  }
  if (programEligibility.isNotEmpty) {
    if (programEligibility.contains("PCM")) {
      query_sub_string_2 = query_sub_string_2 + "pcm_flag: {_eq: true},";
    }
    if (programEligibility.contains("CCM")) {
      query_sub_string_2 = query_sub_string_2 + "ccm_flag: {_eq: true},";
    }
    if (programEligibility.contains("RPM")) {
      query_sub_string_2 = query_sub_string_2 + "rpm_flag: {_eq: true},";
    }
  }
  if (primaryInsList.isNotEmpty) {
    query_sub_string_1 = query_sub_string_1 + "\$primaryInsList: [String!],";
    query_sub_string_2 = query_sub_string_2 +
        "primary_insurance_provider: {_in: \$primaryInsList},";
    request['variables']['primaryInsList'] = primaryInsList;
  }
  if (secondaryInsList.isNotEmpty) {
    query_sub_string_1 = query_sub_string_1 + "\$secondaryInsList: [String!],";
    query_sub_string_2 = query_sub_string_2 +
        "secondary_insurance_provider: {_in: \$secondaryInsList},";
    request['variables']['secondaryInsList'] = secondaryInsList;
  }
  // to remove the trailing commas
  query_sub_string_1 =
      query_sub_string_1.substring(0, query_sub_string_1.length - 1);
  query_sub_string_2 =
      query_sub_string_2.substring(0, query_sub_string_2.length - 1);

  request['query'] =
  "query MyQuery(${query_sub_string_1}) { pep_vw_consolidated_data(where: {${query_sub_string_2}}, limit: ${rpp}, offset: ${pageOffset}) { emr_id provider_name full_name dob primary_dx secondary_dx home_phone_number mobile_phone_number email } }";

  return json.encode(request);
}

dynamic getAppointmentDates(int facilityID) {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_available_clinic_appointments(where: {facility_id: {_eq: $facilityID}}, distinct_on: appointment_date) { appointment_date fmt_appointment_date } }"
  };

  return json.encode(request);
}

dynamic getTwilioCallInformation(String twilioSID) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['twilioSID'] = twilioSID;

  request['query'] =
  "query MyQuery(\$twilioSID: String) { api_outgoing_call_log(where: {twilio_call_sid: {_eq: \$twilioSID}}) { call_status answered_at completed_at call_duration } }";

  return json.encode(request);
}

dynamic getTwilioReceiverCallSID(String callerSID) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['callerSID'] = callerSID;

  request['query'] =
  "query MyQuery(\$callerSID: String) { api_outgoing_call_log(where: {twilio_call_sid: {_eq: \$callerSID}}) { twilio_receiver_call_sid } }";

  return json.encode(request);
}

dynamic getTwilioIncomingCallerCallSID(String callerSID) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['callerSID'] = callerSID;

  request['query'] =
  "query MyQuery(\$callerSID: String) { api_incoming_call_log(where: {twilio_call_sid: {_eq: \$callerSID}}) { parent_call_sid } }";

  return json.encode(request);
}

dynamic getCareSpecialistFollowUpPatientList() {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_cs_task_patient_list(where: {ccm_status_value: {_eq: \"Follow Up\"}}, order_by: {consented_appointment_date_time: desc_nulls_last}) { pep_patient_id patient_clinic_data_id full_name clinic_id clinic_name patient_clinic_timezone consented_appointment_date_time dob provider_name mobile_phone_number ccm_status_value rpm_status_value } }"
  };

  return json.encode(request);
}

dynamic getTransferFeatureRoles() {
  dynamic request = {
    "query":
    "query getTransferRoles { reference_origin_number_type(where: {origin_number_type: {_eq: \"Enrollment\"}}) { transferred_from_role_type transferred_to_role_type } }"
  };

  return json.encode(request);
}

dynamic getUserInfoOfSpecificRoles(String type) {
  dynamic request = {"operationName": "getTransferRoles", "variables": {}};
  request['variables']['type'] = type;

  if (type == "P") {
    request['query'] = "query getTransferRoles(\$type: String!) { api_hboxuser(where: {type: {_neq: \$type}, is_active: {_eq: true}}) { first_name last_name email type } }";
  } else {
    request['query'] = "query getTransferRoles(\$type: String!) { api_hboxuser(where: {type: {_eq: \$type}, is_active: {_eq: true}}) { first_name last_name email type } }";
  }

  return json.encode(request);
}

dynamic getCareSpecialistTransferredPatientList(int assignedCSId) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['assignedCSId'] = assignedCSId;

  request['query'] =
  "query MyQuery(\$assignedCSId: Int!) { pep_vw_transfer_patient_list(where: {_or: [{assigned_cs_id: {_is_null: true}}, {assigned_cs_id: {_eq: \$assignedCSId}}]}) { id pep_patient_clinic_data_id patient_name group_name clinic_id clinic_name vpe_id vpe_name assigned_cs_id added_dt } }";

  return json.encode(request);
}

dynamic getPESFollowUpPatientList(List<int>? clinicIDs) {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_patient_enroller_task_patient_list(where:  {clinic_id: {_in: $clinicIDs},rpm_status_value: {_eq: \"Follow Up\"}}, order_by: {consented_appointment_date_time: desc_nulls_last}) { pep_patient_id patient_clinic_data_id full_name clinic_id clinic_name patient_clinic_timezone consented_appointment_date_time dob provider_name ccm_status_value rpm_status_value } }"
  };

  return json.encode(request);
}

dynamic getPESDeferredPatientList(List<int>? clinicIDs) {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_patient_enroller_task_patient_list(where: {clinic_id: {_in: $clinicIDs},rpm_status_value: {_eq: \"Deferred\"}}, order_by: {consented_appointment_date_time: desc_nulls_last}) { pep_patient_id patient_clinic_data_id full_name clinic_id clinic_name patient_clinic_timezone consented_appointment_date_time dob provider_name ccm_status_value rpm_status_value } }"
  };

  return json.encode(request);
}

dynamic getCareSpecialistClinics(int csID) {
  dynamic request = {
    "query":
    "query MyQuery { pep_care_specialist_active_assignments(where: {care_specialist_id: {_eq: $csID}}) { clinic_ids } }"
  };

  return json.encode(request);
}

dynamic getGroupDetails() {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_group_details(where: {is_archive: {_eq: false}}, order_by: {group_id: desc}) { group_id group_name es_id es_name group_type group_type_id clinic_id clinic_name updated_time_utc patient_clinic_timezone is_archive } }"
  };

  return json.encode(request);
}

List<int> getPatientList(List<dynamic> patientIDs) {
  return patientIDs.cast<int>();
}

dynamic getCreateGroupPatientListByEMR(
    String patientEMRIDs,
    String clinicId,
    ) {
  // Convert comma-separated patientEMRIDs to a List<String>
  List<String> emrIdList =
  patientEMRIDs.split(',').map((e) => e.trim()).toList();

  print('Before Clinic ID: ' + clinicId);
  print('BEFORE EMR IDs: ' + patientEMRIDs);

  print('Clinic ID: ' + clinicId);
  for (int i = 0; i < emrIdList.length; i++) {
    print(emrIdList[i] + '\n');
  }

  dynamic request = {
    "operationName": "MyQuery",
    "variables": {
      "patientEMRIDs": emrIdList,
      "clinicId": int.tryParse(clinicId), // Convert clinicId to int
    },
    "query": """
      query MyQuery(\$patientEMRIDs: [String!], \$clinicId: Int) {
        pep_vw_consolidated_data(where: {emr_id: {_in: \$patientEMRIDs}, _and: {clinic_id: {_eq: \$clinicId}}}) {
          patient_clinic_data_id
          full_name
          dob
          emr_id
          provider_name
          primary_dx
          secondary_dx
        }
      }
    """
  };

  print(json.encode(request));

  return json.encode(request);
}

String getClinicTimezone(
    List<dynamic> clinicIDMapping,
    String clinicName,
    ) {
  for (var mapping in clinicIDMapping) {
    if (mapping['clinic_name'] == clinicName) {
      return mapping['patient_clinic_timezone'];
    }
  }
  return "UTC";
}

String getGroupName(
    List<dynamic> groupNameMapping,
    int groupID,
    ) {
  for (var mapping in groupNameMapping) {
    if (mapping['group_id'] == groupID) {
      return mapping['group_name'];
    }
  }
  return "";
}

dynamic getCallDetails(int patientClinicDataID) {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_consolidated_data(where: {patient_clinic_data_id: {_eq: $patientClinicDataID}}) { call_details } }"
  };

  return json.encode(request);
}

dynamic autofillSearch(
    int clinicID,
    String searchStr,
    ) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['clinicID'] = clinicID;
  request['variables']['searchStr'] = ".*" + searchStr + ".*";

  request['query'] =
  "query MyQuery(\$clinicID: Int!, \$searchStr: String!) { pep_vw_consolidated_data(where: {ccm_status: {_nin: [1,2,3,7,8,9,10]}, search_string: {_iregex: \$searchStr}, clinic_id: {_eq: \$clinicID}}) { search_string } }";

  return json.encode(request);
}

dynamic getArchivedGroupDetails() {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_group_details(where: {is_archive: {_eq: true}}) { group_id group_name es_id es_name group_type group_type_id clinic_id clinic_name updated_time_utc patient_clinic_timezone is_archive } }"
  };

  return json.encode(request);
}

dynamic getEnrollmentSpecialists() {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_enrollment_specialists { hbox_user_id first_name last_name es_name email deferred_task} }"
  };

  return json.encode(request);
}

dynamic getPatientEnrollerDetails() {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_patient_enroller_list { patient_enroller_id first_name last_name full_name email clinic_names clinic_ids deferred_task follow_up } }"
  };

  return json.encode(request);
}

List<int> getClinicIDList(List<dynamic>? clinicIDs) {
  if (clinicIDs == null || clinicIDs.isEmpty) {
    return [];
  }
  return clinicIDs.cast<int>();
}

List<int> generateFilteredPatientsList(
    List<dynamic> filteredPatients,
    bool excludePatientsWithAssignedGroups,
    ) {
  // I have a list of values like this : {"patient_clinic_data_id":58500,"has_active_group":false}, I need to return the list of patient_clinic_data_id where has_active_group is true
  List<int> filteredPatientIds = [];
  for (var patient in filteredPatients) {
    if (excludePatientsWithAssignedGroups) {
      if (patient['has_active_group'] == false) {
        filteredPatientIds.add(patient['patient_clinic_data_id']);
      }
    } else {
      filteredPatientIds.add(patient['patient_clinic_data_id']);
    }
  }
  return filteredPatientIds;
}

dynamic getAssignedGroups(int enrollmentSpecialistID) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['enrollmentSpecialistID'] = enrollmentSpecialistID;

  request['query'] =
  "query MyQuery(\$enrollmentSpecialistID: Int!) { pep_vw_patient_list(where: {enrollment_specialist_id: {_eq: \$enrollmentSpecialistID}}, distinct_on: group_id) { group_id group_name } }";

  return json.encode(request);
}

dynamic getCareSpecialistDetails() {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_care_specialist_list { care_specialist_id first_name last_name full_name email clinic_names clinic_ids deferred_task follow_up } }"
  };

  return json.encode(request);
}

dynamic getNextPatientInGroup(
    int enrollmentSpecialistID,
    int groupID,
    ) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['enrollmentSpecialistID'] = enrollmentSpecialistID;
  request['variables']['groupID'] = groupID;

  request['query'] =
  "query MyQuery(\$enrollmentSpecialistID: Int!, \$groupID: Int!) { pep_vw_patient_list(where: {enrollment_specialist_id: {_eq: \$enrollmentSpecialistID}, group_id: {_eq: \$groupID}}, limit: 1) { pep_patient_clinic_data_id group_id } }";

  return json.encode(request);
}

String getEligibility(
    bool rpmFlag,
    bool ccmFlag,
    bool pcmFlag,
    ) {
  if (rpmFlag == false && ccmFlag == false && pcmFlag == false) {
    return "Not Eligible";
  }

  String return_value = "";

  if (rpmFlag == true) {
    return_value = return_value + "RPM ";
  }
  if (ccmFlag == true) {
    return_value = return_value + "CCM ";
  }
  if (pcmFlag == true) {
    return_value = return_value + "PCM ";
  }
  // to remove the trailing commas
  return_value = return_value.substring(0, return_value.length - 1);

  return return_value;
}

List<int> findCommonPatients(
    List<int> allPatients,
    List<int> patientsByGroupType,
    ) {
  List<int> commonPatients = [];
  for (int patient in allPatients) {
    if (patientsByGroupType.contains(patient)) {
      commonPatients.add(patient);
    }
  }
  return commonPatients;
}

List<int> addSearchPPCIDs(
    List<int> ppcids,
    List<int> currentList,
    ) {
  ppcids.addAll(currentList);
  return ppcids.toSet().toList();
}

dynamic getSingleGroupDetails(int groupId) {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_group_details(where: {group_id: {_eq: $groupId}}) { clinic_name es_id es_name group_id group_name group_type group_type_id updated_time_utc number_of_patients patient_clinic_timezone group_filters } }"
  };

  return json.encode(request);
}

String dtFormatter(DateTime datetime) {
  return datetime.toUtc().toIso8601String();
}

String getClinicName(
    List<dynamic> clinicDetailsMap,
    int clinicID,
    ) {
  for (var mapping in clinicDetailsMap) {
    if (mapping['clinic_id'] == clinicID) {
      return mapping['clinic_name'];
    }
  }
  return "";
}

List<int> subsetPatients(
    int maxAvailablePatients,
    int selectedPatientCount,
    List<int> patientIDs,
    ) {
  if (selectedPatientCount > maxAvailablePatients) {
    selectedPatientCount = maxAvailablePatients;
  }
  return patientIDs.sublist(0, selectedPatientCount);
}

List<String> selectedDatesForClinicTimings(
    DateTime startDate,
    DateTime endDate,
    List<String> daysOfTheWeek,
    ) {
  List<DateTime> selectedDays = [];
  endDate = endDate.add(Duration(days: 1));
  DateTime currentDate = startDate;
  while (currentDate.isBefore(endDate)) {
    if (daysOfTheWeek.contains('Monday') &&
        currentDate.weekday == DateTime.monday) {
      selectedDays.add(currentDate);
    }
    if (daysOfTheWeek.contains('Tuesday') &&
        currentDate.weekday == DateTime.tuesday) {
      selectedDays.add(currentDate);
    }
    if (daysOfTheWeek.contains('Wednesday') &&
        currentDate.weekday == DateTime.wednesday) {
      selectedDays.add(currentDate);
    }
    if (daysOfTheWeek.contains('Thursday') &&
        currentDate.weekday == DateTime.thursday) {
      selectedDays.add(currentDate);
    }
    if (daysOfTheWeek.contains('Friday') &&
        currentDate.weekday == DateTime.friday) {
      selectedDays.add(currentDate);
    }
    currentDate = currentDate.add(Duration(days: 1));
  }
//  return selectedDays;

  List<String> selectedDaysList = selectedDays
      .map((datetime) => DateFormat('yyyy-MM-dd').format(datetime))
      .toList();
  return selectedDaysList;
}

List<String> suggestedVitalsDropDown(List<String> suggestedVitals) {
  List<String> result = [];
  for (String vital in suggestedVitals) {
    List<String> splitVital = vital.split(',');
    for (String v in splitVital) {
      if ((v != null && v != 'null') && !result.contains(v)) {
        result.add(v);
      }
    }
  }
  return result;
}

List<int> getConditions(
    int? primaryDx,
    int? secondaryDx,
    ) {
  List<int> returnValue = [];
  if (primaryDx != null) {
    returnValue.add(primaryDx);
  }
  if (secondaryDx != null) {
    returnValue.add(secondaryDx);
  }
  return returnValue;
}

String generateVPEUpadateUserBody(
    String firstName,
    String lastName,
    String email,
    String password,
    String taskAssigned,
    ) {
  dynamic request = {};
  request['first_name'] = firstName;
  request['last_name'] = lastName;
  request['task_assigned'] = taskAssigned;
  request['email'] = email;
  if (password != '') {
    request['password'] = password;
  }

  return json.encode(request);
}

dynamic searchForPESPatientID(String searchStr) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['searchStr'] = searchStr;

  request['query'] =
  "query MyQuery(\$searchStr: String!) { pep_vw_patient_enroller_patient_list(where: {search_string: {_eq: \$searchStr}}) { patient_clinic_data_id clinic_id } }";

  return json.encode(request);
}

String returnTime(DateTime dt) {
  return DateFormat('HH:mm:ss').format(dt);
}

String? returnDate(DateTime dt) {
  return DateFormat('yyyy-MM-dd').format(dt);
}

dynamic getCSUpdateClinics(
    List<dynamic> clinicList,
    List<int> clinics,
    ) {
  List<dynamic> availableClinics = [];
  for (var clinic in clinicList) {
    if (clinics.contains(clinic['clinic_id']) ||
        clinic['has_active_cs'] == false) {
      availableClinics.add(clinic);
    }
  }
  return {'pep_vw_available_clinics': availableClinics};
}

dynamic getAlllPatients() {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_consolidated_data(limit:100) { full_name clinic_name email } }"
  };

  return json.encode(request);
}

dynamic searchPatients(String searchStr) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['searchStr'] = "%" + searchStr + "%";

  request['query'] =
  "query MyQuery(\$searchStr: String!) { pep_vw_consolidated_data(where: {search_string: {_ilike: \$searchStr}},limit: 100) { full_name clinic_name email } }";

  return json.encode(request);
}

dynamic groupFiltersUsed(
    String clinic,
    List<String>? facilities,
    List<String>? providers,
    List<String>? primaryDx,
    List<String>? secondaryDx,
    List<String>? programEligibility,
    List<String>? primaryInsurance,
    List<String>? secondaryInsurance,
    List<String>? insuranceTypes,
    List<String>? groupTypes,
    String? zipcodes,
    DateTime? lastVisitDate,
    bool excludeFlag,
    int clinicID,
    List<int>? facilityID,
    List<int>? providerID,
    ) {
  final Map<String, dynamic> filters = {};

  filters['clinic'] = clinic;
  filters['clinicID'] = clinicID;

  if (facilities != null && facilities.isNotEmpty) {
    filters['facilities'] = facilities;
  }

  if (providers != null && providers.isNotEmpty) {
    filters['providers'] = providers;
  }

  if (facilityID != null && facilityID.isNotEmpty) {
    filters['facilityID'] = facilityID;
  }

  if (providerID != null && providerID.isNotEmpty) {
    filters['providerID'] = providerID;
  }

  if (primaryDx != null && primaryDx.isNotEmpty) {
    filters['primaryDx'] = primaryDx;
  }

  if (secondaryDx != null && secondaryDx.isNotEmpty) {
    filters['secondaryDx'] = secondaryDx;
  }

  if (programEligibility != null && programEligibility.isNotEmpty) {
    filters['programEligibility'] = programEligibility;
  }

  if (primaryInsurance != null && primaryInsurance.isNotEmpty) {
    filters['primaryInsurance'] = primaryInsurance;
  }

  if (secondaryInsurance != null && secondaryInsurance.isNotEmpty) {
    filters['secondaryInsurance'] = secondaryInsurance;
  }

  if (insuranceTypes != null && insuranceTypes.isNotEmpty) {
    filters['insuranceTypes'] = insuranceTypes;
  }

  if (groupTypes != null && groupTypes.isNotEmpty) {
    filters['groupTypes'] = groupTypes;
  }

  if (zipcodes != null && zipcodes.isNotEmpty) {
    filters['zipcodes'] = zipcodes;
  }

  if (lastVisitDate != null) {
    filters['lastVisitDate'] = DateFormat('yyyy-MM-dd').format(lastVisitDate);
  }

  filters['excludeFlag'] = excludeFlag;

  return filters;
}

List<int> returnIntList(List<dynamic>? inputList) {
  // accept a dynamic list and return an int list
  List<int> outputList = [];
  if (inputList != null) {
    for (dynamic item in inputList) {
      if (item is int) {
        outputList.add(item);
      }
    }
  }
  return outputList;
}

String? returnSMSTemplateFromTitle(
    int templateId,
    dynamic content,
    ) {
  if (content == null) return null;

  try {
    // Ensure content is a List
    if (content is! List) return null;

    print("Id: $templateId");
    print("Content: $content");

    // Find the matching template by title
    var matchingTemplate = content.firstWhere(
          (template) =>
      template is Map<String, dynamic> && template['id'] == templateId,
      orElse: () => <String, dynamic>{}, // Ensuring an empty Map
    );

    print("Matching Template: $matchingTemplate");

    if (matchingTemplate is! Map<String, dynamic> || matchingTemplate.isEmpty)
      return null;

    String? smsTemplate = matchingTemplate['sms_template'] as String?;

    print("SMS Template: $smsTemplate");

    return smsTemplate;
  } catch (e) {
    print("Error: $e");
    return null; // Return null instead of throwing an error
  }
}

DateTime? returnDT(String inputString) {
  if (inputString == null || inputString == '') {
    return null;
  }
  return DateTime.parse(inputString);
}

List<String> returnProgramEligibility(
    bool? rpmflag,
    bool? ccmflag,
    bool? pcmflag,
    ) {
  // you start with an empty string list and add RPM as an element if rpmflag is true and not null and so on
  List<String> eligibility = [];

  if (rpmflag != null && rpmflag) {
    eligibility.add('RPM');
  }

  if (ccmflag != null && ccmflag) {
    eligibility.add('CCM');
  }

  if (pcmflag != null && pcmflag) {
    eligibility.add('PCM');
  }

  return eligibility;
}

List<dynamic> returnFiltersUsed(dynamic input) {
  List<dynamic> output = [];

  if (input.containsKey('clinic')) {
    output.add({"key": "Clinic Name", "value": input['clinic'].toString()});
  }
  if (input.containsKey('facilities')) {
    output.add({
      "key": "Facility Names",
      "value": input['facilities']
          .toString()
          .substring(1, input['facilities'].toString().length - 1)
    });
  }
  if (input.containsKey('providers')) {
    output.add({
      "key": "Provider Name",
      "value": input['providers']
          .toString()
          .substring(1, input['providers'].toString().length - 1)
    });
  }
  if (input.containsKey('primaryDx')) {
    output.add({
      "key": "Primary Dx",
      "value": input['primaryDx']
          .toString()
          .substring(1, input['primaryDx'].toString().length - 1)
    });
  }
  if (input.containsKey('secondaryDx')) {
    output.add({
      "key": "Secondary Dx",
      "value": input['secondaryDx']
          .toString()
          .substring(1, input['secondaryDx'].toString().length - 1)
    });
  }
  if (input.containsKey('programEligibility')) {
    output.add({
      "key": "Pre Enroll Eligibility",
      "value": input['programEligibility']
          .toString()
          .substring(1, input['programEligibility'].toString().length - 1)
    });
  }
  if (input.containsKey('primaryInsurance')) {
    output.add({
      "key": "Primary Insurance",
      "value": input['primaryInsurance']
          .toString()
          .substring(1, input['primaryInsurance'].toString().length - 1)
    });
  }
  if (input.containsKey('secondaryInsurance')) {
    output.add({
      "key": "Secondary Insurance",
      "value": input['secondaryInsurance']
          .toString()
          .substring(1, input['secondaryInsurance'].toString().length - 1)
    });
  }
  if (input.containsKey('insuranceTypes')) {
    output.add({
      "key": "Insurance Types",
      "value": input['insuranceTypes']
          .toString()
          .substring(1, input['insuranceTypes'].toString().length - 1)
    });
  }
  if (input.containsKey('groupTypes')) {
    output.add({
      "key": "Group Types",
      "value": input['groupTypes']
          .toString()
          .substring(1, input['groupTypes'].toString().length - 1)
    });
  }
  if (input.containsKey('zipcodes')) {
    output.add({"key": "Zip Codes", "value": input['zipcodes'].toString()});
  }
  if (input.containsKey('lastVisitDate')) {
    output.add(
        {"key": "Last Visit Date", "value": input['lastVisitDate'].toString()});
  }
  if (input.containsKey('excludeFlag')) {
    output.add({
      "key": "Exclude Patients with Assigned Groups",
      "value": input['excludeFlag'].toString().toUpperCase()
    });
  }

  return output;
}

String patientUpdateGlobal(
    int? ccmStatus,
    String? ccmAppointmentDT,
    List<String>? ccmVitals,
    int? rpmStatus,
    String? rpmAppointmentDate,
    String? rpmAppointmentTime,
    int? rpmAppointmentFacility,
    List<String>? rpmVitals,
    String? emrID,
    List<String>? programEligibility,
    int? providerID,
    int? pepPatientID,
    String? firstName,
    String? lastName,
    DateTime? dob,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? zipcode,
    String? homeNumber,
    String? mobileNumber,
    String? email,
    String? insuranceType,
    String? primaryInsurance,
    String? secondaryInsurance,
    String? primaryInsuranceNumber,
    String? secondaryInsuranceNumber,
    bool globalFlag,
    String? comment,
    int? primaryDx,
    int? secondaryDx,
    int? groupId,
    bool deferredQueue,
    bool isTransferPatient,
    ) {
  final dateFormat = DateFormat('yyyy-MM-dd');
  final dobString = dob != null ? dateFormat.format(dob) : null;

  // if (ccmStatus != 1 && ccmStatus != 3) {
  //   ccmAppointmentDT == null;
  // }

  if (ccmStatus == 10) {
    ccmAppointmentDT == null;
  }

  if ((ccmStatus == 1 || ccmStatus == 3) &&
      (ccmAppointmentDT == null || ccmAppointmentDT == '')) {
    ccmStatus = null;
    ccmAppointmentDT = null;
  }
  if (ccmStatus == 0) {
    ccmStatus = null;
    ccmAppointmentDT = null;
  }

  if (rpmStatus != 2 && rpmStatus != 7) {
    rpmAppointmentDate = null;
    rpmAppointmentTime = null;
    rpmAppointmentFacility = null;
  }
  if ((rpmStatus == 2) &&
      (rpmAppointmentDate == null ||
          rpmAppointmentDate == '' ||
          rpmAppointmentTime == null ||
          rpmAppointmentTime == '' ||
          rpmAppointmentFacility == null ||
          rpmAppointmentFacility == '')) {
    rpmStatus = null;
    rpmAppointmentDate = null;
    rpmAppointmentTime = null;
    rpmAppointmentFacility = null;
  }
  if ((rpmStatus == 7) &&
      (rpmAppointmentDate == null ||
          rpmAppointmentDate == '' ||
          rpmAppointmentTime == null ||
          rpmAppointmentTime == '' ||
          rpmAppointmentFacility == null ||
          rpmAppointmentFacility == '')) {
    rpmAppointmentDate = null;
    rpmAppointmentTime = null;
    rpmAppointmentFacility = null;
  }
  if (rpmStatus == 0) {
    rpmStatus = null;
    rpmAppointmentDate = null;
    rpmAppointmentTime = null;
    rpmAppointmentFacility = null;
  }

  if (ccmStatus == null && rpmStatus == null && !isTransferPatient) {
    comment = null;
  }

  Map<String, dynamic> returnValue = {
    "global_flag": globalFlag,
    "ccm_status": ccmStatus,
    "ccm_appointmentDate": ccmAppointmentDT,
    "rpm_status": rpmStatus,
    "rpm_appointment_date": rpmAppointmentDate,
    "rpm_appointment_time": rpmAppointmentTime,
    "rpm_appointment_facility": rpmAppointmentFacility,
    "comment": comment,
    "ccm_vitals": ccmVitals,
    "rpm_vitals": rpmVitals,
    "pep_patient_id": pepPatientID,
    "provider_id": providerID,
    "emr_id": emrID,
    "primary_condition": primaryDx,
    "secondary_condition": secondaryDx,
    "first_name": firstName,
    "last_name": lastName,
    "dob": dobString,
    "gender": gender,
    "address_line_1": address,
    "city": city,
    "state": state,
    "zip_code": zipcode,
    "email_address": email,
    "home_number": homeNumber,
    "mobile_number": mobileNumber,
    "insurance_type": insuranceType,
    "primary_insurance": primaryInsurance,
    "primary_insurance_number": primaryInsuranceNumber,
    "secondary_insurance": secondaryInsurance,
    "secondary_insurance_number": secondaryInsuranceNumber,
    "program_eligibility": programEligibility,
    "group_id": groupId,
    "deferred_queue": deferredQueue,
  };
  returnValue.removeWhere((key, value) => value == null);
  return json.encode(returnValue);
}

DateTime? timeZoneConverter(String dateTime) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final DateTime parsedDateTime = formatter.parse(dateTime);

  // Convert the parsedDateTime from IST to UTC (IST is UTC+5:30)
  final DateTime utcDateTime =
  parsedDateTime.subtract(const Duration(hours: 5, minutes: 30));

  // Find the second Sunday of March (start of daylight saving for EST/EDT)
  final marchSecondSunday = DateTime(utcDateTime.year, DateTime.march, 1).add(
      Duration(
          days:
          (7 - DateTime(utcDateTime.year, DateTime.march, 1).weekday) % 7 +
              7));

  // Find the first Sunday of November (end of daylight saving for EST/EDT)
  final novemberFirstSunday = DateTime(utcDateTime.year, DateTime.november, 1)
      .add(Duration(
      days: (7 - DateTime(utcDateTime.year, DateTime.november, 1).weekday) %
          7));

  // Daylight saving time starts and ends at 2 AM local time
  final startDaylightSaving = marchSecondSunday.add(const Duration(hours: 2));
  final endDaylightSaving = novemberFirstSunday.add(const Duration(hours: 2));

  // Check if the given datetime is within daylight saving time
  final bool isDaylightSaving = utcDateTime.isAfter(startDaylightSaving) &&
      utcDateTime.isBefore(endDaylightSaving);

  // If it's daylight saving time, adjust accordingly for EDT (UTC-4)
  if (isDaylightSaving) {
    return utcDateTime.subtract(const Duration(hours: 4)); // EDT (UTC-4)
  }
  // Otherwise, adjust for standard EST (UTC-5)
  else {
    return utcDateTime.subtract(const Duration(hours: 5)); // EST (UTC-5)
  }
}

List<int> returnSelectedPatients(
    List<int>? selectedIndex,
    dynamic requestBody,
    ) {
  final List<dynamic> dataList =
  requestBody['data']['pep_vw_consolidated_data'];
  final List<int> selectedPatients = [];

  if (selectedIndex == null || selectedIndex.isEmpty) {
    for (final data in dataList) {
      final int patientId = data['patient_clinic_data_id'];
      selectedPatients.add(patientId);
    }
  } else {
    for (int index in selectedIndex) {
      if (index >= 0 && index < dataList.length) {
        final Map<String, dynamic> data = dataList[index];
        final int patientId = data['patient_clinic_data_id'];
        selectedPatients.add(patientId);
      }
    }
  }
  return selectedPatients;
}

dynamic dropDownGlobalSearch(
    String selectedDropdownValue,
    String searchString,
    ) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};

  // Ensure the dropdown value is trimmed to avoid comparison issues
  String dropdownValue = selectedDropdownValue.trim();

  // Build the dynamic search field based on dropdown value
  String fieldToSearch;
  switch (dropdownValue) {
    case "1":
      fieldToSearch = "full_name";
      request['variables']['searchStr'] = ".*" + searchString.trim() + ".*";
      break;
    case "2":
      fieldToSearch = "dob";
      request['variables']['searchStr'] =
          searchString.trim(); // No regex for dates
      break;
    case "3":
      fieldToSearch = "emr_id";
      request['variables']['searchStr'] = ".*" + searchString.trim() + ".*";
      break;
    case "4":
      fieldToSearch = "home_phone_number";
      request['variables']['searchStr'] = ".*" + searchString.trim() + ".*";
      break;
    case "5":
      fieldToSearch = "mobile_phone_number";
      request['variables']['searchStr'] = ".*" + searchString.trim() + ".*";
      break;
    case "6":
      fieldToSearch = "clinic_name";
      request['variables']['searchStr'] = ".*" + searchString.trim() + ".*";
      break;
    default:
      fieldToSearch =
      "full_name"; // Fallback to full_name if no option is selected
      request['variables']['searchStr'] = ".*" + searchString.trim() + ".*";
  }

  // Use _eq for the DOB (date) field and _iregex for other fields
  if (fieldToSearch == "dob") {
    request['query'] = """
      query MyQuery(\$searchStr: date!) {
        pep_vw_consolidated_data(
          where: { dob: { _eq: \$searchStr } }
          limit: 100
        ) {
          pep_patient_id
          patient_clinic_data_id
          full_name
          dob
          home_phone_number
          mobile_phone_number
          email
          clinic_id
          clinic_name
          emr_id
        }
      }
    """;
  } else {
    request['query'] = """
      query MyQuery(\$searchStr: String!) {
        pep_vw_consolidated_data(
          where: { $fieldToSearch: { _iregex: \$searchStr } }
          limit: 100
        ) {
          pep_patient_id
          patient_clinic_data_id
          full_name
          dob
          home_phone_number
          mobile_phone_number
          email
          clinic_id
          clinic_name
          emr_id
        }
      }
    """;
  }

  return json.encode(request);
}

List<dynamic>? filterGroupLocally(
    List<dynamic>? groupDetails,
    String? searchKey,
    String? searchValue,
    ) {
  if (groupDetails == null || searchKey == null || searchValue == null) {
    return null;
  }

  return groupDetails.where((group) {
    final value = group[searchKey];
    if (value is String) {
      return value.toLowerCase().contains(searchValue.toLowerCase());
    }
    return false;
  }).toList();
}

List<dynamic> enrichClinicTime(List<dynamic> patientList) {
  if (patientList.isEmpty) {
    return patientList;
  }

  patientList.forEach((patient) {
    String? consented_appointment_date_time =
    patient['consented_appointment_date_time'];
    String? patient_clinic_timezone = patient['patient_clinic_timezone'];
    DateTime clinic_time_appointment = DateTime.now();

    if (consented_appointment_date_time != null &&
        patient_clinic_timezone != null) {
      clinic_time_appointment = dtReturnFormatter(
          consented_appointment_date_time, patient_clinic_timezone);
      patient['clinic_time_appointment'] =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(clinic_time_appointment);
    }
  });
  return patientList;
}

List<dynamic>? filterCSListLocally(
    List<dynamic>? csList,
    String? searchKey,
    String? searchValue,
    ) {
  if (csList == null || searchKey == null || searchValue == null) {
    return null;
  }

  print("search Value: ${searchValue}"); // Print the input list
  print("search Key: ${searchKey}"); // Print the input list

  return csList.where((patient) {
    final value = patient[searchKey];
    if (value is String) {
      return value.toLowerCase().contains(searchValue.toLowerCase());
    }
    return false;
  }).toList();
}

String returnUsername(
    List<dynamic>? usernames,
    int? uid,
    ) {
  if (usernames == null || uid == null) {
    return "N/A";
  } else {
    final user =
    usernames.firstWhere((user) => user['id'] == uid, orElse: () => {});
    if (!user.isEmpty) {
      return usertype(user['type']) +
          user['first_name'] +
          ' ' +
          user['last_name'];
    }
    return "N/A";
  }
}

String usertype(String? usertypeVar) {
  if (usertypeVar == null) {
    return "";
  } else {
    switch (usertypeVar) {
      case 'EA':
        return "VPE Admin : ";
      case 'ES':
        return "VPE : ";
      case 'CA':
        return "CS Admin : ";
      case 'CS':
        return "CS : ";
      case 'PA':
        return "PES Admin : ";
      case 'PE':
        return "PES : ";
      default:
        return "";
    }
  }
}

DateTime? datetimeStringToDT(String datetimeString) {
  // Sample Input "2024-10-08T05:26:47.804276800Z" I need this output in utc time in this format 2023-09-27 16:00:00
  DateTime? dateTime = DateTime.tryParse(datetimeString);
  if (dateTime != null) {
    DateTime utcDateTime = dateTime.toUtc();
    String formattedDateTime =
    DateFormat('yyyy-MM-dd HH:mm:ss').format(utcDateTime);
    return DateTime.parse(formattedDateTime);
  }
  return null;
}

List<String>? getSelectedVPES(List<String> selectedVPEs) {
  return selectedVPEs.isEmpty ? [] : selectedVPEs;
}

dynamic flowgroupFiltersUsedEMRFlow(
    String clinic,
    int clinicID,
    ) {
  final Map<String, dynamic> filters = {};

  filters['clinic'] = clinic;
  filters['clinicID'] = clinicID;

  return filters;
}

dynamic getVPEDeferredPataients(int patientClinicDataID) {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_consolidated_data(where:  {patient_clinic_data_id: {_eq: $patientClinicDataID}}) { first_name last_name dob gender mobile_phone_number home_phone_number email address_line_1 city state zip_code clinic_name facility_id facility_name emr_id provider_id provider_name primary_dx primary_dx_id secondary_dx secondary_dx_id primary_insurance_provider primary_insurance_id secondary_insurance_provider secondary_insurance_id rpm_flag ccm_flag pcm_flag pep_patient_id patient_clinic_timezone ccm_status rpm_status ccm_appointment_dt rpm_appointment_dt ccm_vitals clinic_id} }"
  };

  return json.encode(request);
}

dynamic getSMStemplates() {
  dynamic request = {
    "query": "query MyQuery { pep_sms_template { id sms_title sms_template }}",
  };
  return json.encode(request);
}

String getDeferredPatientId() {
  dynamic request = {
    "query":
    " query MyQuery {pep_vw_vpe_deferred_list(limit: 1) {pep_patient_clinic_data_id}}"
  };

  return json.encode(request);
}

int getRealTimeTransferPatientCount(List<dynamic> patientList) {
  return patientList.length;
}

bool isPatientAlreadyEnrolled(List<dynamic> jsonList) {
  bool hasEnrolled = jsonList
      .any((item) => item['status']?.toString().contains('Enrolled') == true);

  for (var item in jsonList) {
    if (item['status']?.toString().contains('Enrolled') == true) {
      // print("Found ENROLLED: ${item['timestamp']}");
    }
  }

  return hasEnrolled;
}

dynamic checkTaskAssigned(String vpeId) {
  dynamic request = {
    "query":
    "query MyQuery { pep_task_assignment(where: { user_id: { _eq: $vpeId  } }) { is_deleted  } }"
  };

  return json.encode(request);
}

dynamic checkVpeForDeferredPatients(String vpeId) {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_enrollment_specialists(where: {hbox_user_id: {_eq: $vpeId}}) { deferred_task hbox_user_id }}"
  };

  return json.encode(request);
}

dynamic getSavedVPEDeferredPatient(String patientClinicDataID) {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_consolidated_data(where:  {patient_clinic_data_id: {_eq: $patientClinicDataID}}) { first_name last_name dob gender mobile_phone_number home_phone_number email address_line_1 city state zip_code clinic_name facility_id facility_name emr_id provider_id provider_name primary_dx primary_dx_id secondary_dx secondary_dx_id primary_insurance_provider primary_insurance_id secondary_insurance_provider secondary_insurance_id rpm_flag ccm_flag pcm_flag pep_patient_id patient_clinic_timezone ccm_status rpm_status ccm_appointment_dt rpm_appointment_dt ccm_vitals clinic_id} }"
  };

  return json.encode(request);
}

List<dynamic> sortAttemptsToDesc(List<dynamic> jsonList) {
  jsonList.sort((a, b) => b['id'].compareTo(a['id']));
  return jsonList;
}

List<String> decodeSelectedStatuses(String? selectedStatuses) {
// Check if selectedStatuses is null or empty
  if (selectedStatuses == null || selectedStatuses.isEmpty) {
    // Return an empty list if the value is null or empty
    return [];
  }

  try {
    // Decode the JSON string and cast it to a List<String>
    var decodedList = json.decode(selectedStatuses).cast<String>();

    // Print the decoded list to console
    print("Decoded Selected Statuses: $decodedList");

    // Return the decoded list of strings
    return decodedList;
  } catch (e) {
    // Handle potential errors gracefully (e.g., corrupted JSON)
    print("Error decoding selectedStatuses: $e");
    return [];
  }
}

String encodeStringListToJson(List<String>? selectedValues) {
// Encode the list of selected values to JSON
  String encodedValues = json.encode(selectedValues);

  print("String Selected Values: $selectedValues");

  // Print the encoded JSON string to the console
  print("Encoded Selected Values: $encodedValues");

  return encodedValues;
}

List<dynamic>? filterPESListByCCMAndRPMLocally(
    List<dynamic>? pesList,
    List<String>? searchValuesCCM,
    List<String>? searchValuesRPM,
    ) {
  if (pesList == null || searchValuesCCM == null || searchValuesRPM == null) {
    return null;
  }

  print("CCM Search Values: $searchValuesCCM");
  print("RPM Search Values: $searchValuesRPM");
  print("Original PES List (${pesList.length} items): $pesList");

  final filteredList = pesList.where((patient) {
    final ccmValue = patient['ccm_status_value'];
    final rpmValue = patient['rpm_status_value'];

    if (ccmValue is! String || rpmValue is! String) {
      print("Skipping item. Invalid values.");
      return false;
    }

    final lowerCCM = ccmValue.toLowerCase();
    final lowerRPM = rpmValue.toLowerCase();

    final matchCCM = searchValuesCCM.isEmpty
        ? true
        : searchValuesCCM.any((v) => lowerCCM.contains(v.toLowerCase()));

    final matchRPM = searchValuesRPM.isEmpty
        ? true
        : searchValuesRPM.any((v) => lowerRPM.contains(v.toLowerCase()));

    return matchCCM && matchRPM;
  }).toList();

  print("Filtered PES List (${filteredList.length} items): $filteredList");

  return filteredList;
}

dynamic getCareSpecialistDeferredPatientList() {
  dynamic request = {
    "query":
    "query MyQuery { pep_vw_cs_task_patient_list(where: {ccm_status_value: {_eq: \"Deferred (CS)\"}}, order_by: {consented_appointment_date_time: desc_nulls_last}) { pep_patient_id patient_clinic_data_id full_name clinic_id clinic_name patient_clinic_timezone consented_appointment_date_time dob provider_name mobile_phone_number ccm_status_value rpm_status_value } }"
  };

  return json.encode(request);
}

List<dynamic>? filterCSListByCCMAndRPMLocally(
    List<dynamic>? csList,
    List<String>? searchValuesCCM,
    List<String>? searchValuesRPM,
    ) {
  if (csList == null || searchValuesCCM == null || searchValuesRPM == null) {
    return null;
  }

  print("CCM Search Values: $searchValuesCCM");
  print("RPM Search Values: $searchValuesRPM");
  print("Original CS List (${csList.length} items): $csList");

  final filteredList = csList.where((patient) {
    final ccmValue = patient['ccm_status_value'];
    final rpmValue = patient['rpm_status_value'];

    if (ccmValue is! String || rpmValue is! String) {
      print("Skipping item. Invalid values.");
      return false;
    }

    final lowerCCM = ccmValue.toLowerCase();
    final lowerRPM = rpmValue.toLowerCase();

    final matchCCM = searchValuesCCM.isEmpty
        ? true
        : searchValuesCCM.any((v) => lowerCCM.contains(v.toLowerCase()));

    final matchRPM = searchValuesRPM.isEmpty
        ? true
        : searchValuesRPM.any((v) => lowerRPM.contains(v.toLowerCase()));

    return matchCCM && matchRPM;
  }).toList();

  print("Filtered CS List (${filteredList.length} items): $filteredList");

  return filteredList;
}

List<dynamic>? filterPESListByCCMOrRPMLocally(
    List<dynamic>? pesList,
    String? searchKey,
    List<String>? searchValues,
    ) {
  if (pesList == null || searchKey == null || searchValues == null) {
    return null;
  }

  return pesList.where((patient) {
    final value = patient[searchKey];
    if (value is String) {
      final valueLower = value.toLowerCase();
      return searchValues.any((sv) => valueLower.contains(sv.toLowerCase()));
    }
    return false;
  }).toList();
}

List<dynamic>? filterCSListByCCMOrRPMLocally(
    List<dynamic>? csList,
    String? searchKey,
    List<String>? searchValues,
    ) {
  if (csList == null || searchKey == null || searchValues == null) {
    return null;
  }

  print("search Key: $searchKey");
  print("search Values: $searchValues");

  return csList.where((patient) {
    final value = patient[searchKey];
    if (value is String) {
      return searchValues.any(
              (searchVal) => value.toLowerCase().contains(searchVal.toLowerCase()));
    }
    return false;
  }).toList();
}

bool isFilterApplied(List<dynamic>? csPatientsFiltered) {
  if (csPatientsFiltered == null) return false;
  return csPatientsFiltered.isEmpty;
}

List<int> returnSelectedTimeSlotIDs(
    List<int>? selectedIndex,
    dynamic requestBody,
    ) {
  final List<dynamic> dataList =
  requestBody['data']['pep_vw2_clinic_appointments'];
  final List<int> selectedSlotIDs = [];

  if (selectedIndex != null && selectedIndex.isNotEmpty) {
    for (int index in selectedIndex) {
      if (index >= 0 && index < dataList.length) {
        final Map<String, dynamic> data = dataList[index];
        final int slotId = data['appointment_id'];
        selectedSlotIDs.add(slotId);
      }
    }
  }

  print('Selected indices: $selectedIndex');
  print('Slot IDs: $selectedSlotIDs');

  return selectedSlotIDs;
}

String formatPhoneNumber(String phone) {
  if (phone.length != 10 || !RegExp(r'^\d{10}$').hasMatch(phone)) {
    return phone; // Return unformatted if input is invalid
  }

  final formatted =
      '${phone.substring(0, 3)}-${phone.substring(3, 6)}-${phone.substring(6)}';
  return formatted;
}

List<dynamic>? filterCSDeferredListLocally(
    List<dynamic>? csDeferredList,
    String? searchKey,
    String? searchValue,
    ) {
  if (csDeferredList == null || searchKey == null || searchValue == null) {
    return null;
  }

  print("search Value: ${searchValue}"); // Print the input list
  print("search Key: ${searchKey}"); // Print the input list

  return csDeferredList.where((patient) {
    final value = patient[searchKey];
    if (value is String) {
      return value.toLowerCase().contains(searchValue.toLowerCase());
    }
    return false;
  }).toList();
}

List<dynamic>? filterCSFollowUpListLocally(
    List<dynamic>? csFollowUpList,
    String? searchKey,
    String? searchValue,
    ) {
  if (csFollowUpList == null || searchKey == null || searchValue == null) {
    return null;
  }

  print("search Value: ${searchValue}"); // Print the input list
  print("search Key: ${searchKey}"); // Print the input list

  final filteredList = csFollowUpList.where((patient) {
    final value = patient[searchKey];
    if (value is String) {
      return value.toLowerCase().contains(searchValue.toLowerCase());
    }
    return false;
  }).toList();

  return filteredList;
}

dynamic getTwilioIncomingCallInformation(String twilioSID) {
  dynamic request = {"operationName": "MyQuery", "variables": {}};
  request['variables']['twilioSID'] = twilioSID;

  request['query'] =
  "query MyQuery(\$twilioSID: String) { api_incoming_call_log(where: {twilio_call_sid: {_eq: \$twilioSID}}) { call_status answered_at completed_at call_duration } }";

  return json.encode(request);
}

List<dynamic>? filterAppointmentListUsingRangeLocally(
    List<dynamic>? appointmentList,
    List<String>? appointmentFacility,
    dynamic filterData,
    ) {
  if (appointmentFacility != null && appointmentFacility.isNotEmpty) {
    appointmentList?.removeWhere(
            (item) => !appointmentFacility.contains(item['facility_name']));
  }

  // Parse filter start and end DateTime
  final DateTime filterStartDateTime = DateTime.parse(
      '${filterData['startDate']}T${filterData['startTime']}:00');
  final DateTime filterEndDateTime =
  DateTime.parse('${filterData['endDate']}T${filterData['endTime']}:00');

  appointmentList?.removeWhere((item) {
    // Parse appointment date and times
    final String appointmentDate =
    item['appointment_date']; // e.g. '2025-06-11'
    final String appointmentStartTime = DateFormat.Hm().format(
        DateFormat.jm().parse(item['appointment_start_time'])); // e.g. '10:30'
    final String appointmentEndTime = DateFormat.Hm().format(
        DateFormat.jm().parse(item['appointment_end_time'])); // e.g. '11:30'

    // Construct DateTime objects for appointment start and end
    final DateTime appointmentStartDateTime =
    DateTime.parse('$appointmentDate' + 'T' + '$appointmentStartTime:00');
    final DateTime appointmentEndDateTime =
    DateTime.parse('$appointmentDate' + 'T' + '$appointmentEndTime:00');

    // Check if appointment overlaps with the filter range
    // Overlap condition: appointment starts before filter end AND appointment ends after filter start
    final bool isOutsideRange =
        appointmentEndDateTime.isBefore(filterStartDateTime) ||
            appointmentStartDateTime.isAfter(filterEndDateTime);

    // Remove if outside range
    return isOutsideRange;
  });

  return appointmentList;
}

List<int>? filterNotAssignedAppointments(List<dynamic>? appointments) {
  appointments?.removeWhere((item) => item['patient_clinic_data_id'] != null);
  final filteredItems =
  List<int>.from((appointments ?? []).map((e) => e['appointment_id']));
  return filteredItems;
}
