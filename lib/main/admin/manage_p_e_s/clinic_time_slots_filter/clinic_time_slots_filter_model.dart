import '/flutter_flow/flutter_flow_util.dart';
import 'clinic_time_slots_filter_widget.dart' show ClinicTimeSlotsFilterWidget;
import 'package:flutter/material.dart';

class ClinicTimeSlotsFilterModel
    extends FlutterFlowModel<ClinicTimeSlotsFilterWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  DateTime? datePicked1;
  DateTime? datePicked2;
  DateTime? datePicked3;
  DateTime? datePicked4;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
