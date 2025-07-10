// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/main/admin/manage_p_e_s/manage_clinic_time_slots/manage_clinic_time_slots_widget.dart'; // Import your widget file here

// Future<void> refreshPESDataTableClinicTimeSlots(BuildContext context) async {
//   Navigator.pushReplacementNamed(
//     context,
//     '/ManageClinicTime',
//   );
// }
Future<void> refreshManageClinicTimeSlots(BuildContext context) async {
  context.goNamed('ManageClinicTimeSlots');
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
