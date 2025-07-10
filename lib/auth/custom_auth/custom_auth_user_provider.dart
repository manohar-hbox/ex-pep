import 'package:rxdart/rxdart.dart';

import '/backend/schema/structs/index.dart';
import 'custom_auth_manager.dart';

class PatientEnrollmentProgramAuthUser {
  PatientEnrollmentProgramAuthUser({
    required this.loggedIn,
    this.uid,
    this.userData,
  });

  bool loggedIn;
  String? uid;
  UserStruct? userData;
}

/// Generates a stream of the authenticated user.
BehaviorSubject<PatientEnrollmentProgramAuthUser>
    patientEnrollmentProgramAuthUserSubject =
    BehaviorSubject.seeded(PatientEnrollmentProgramAuthUser(loggedIn: false));
Stream<PatientEnrollmentProgramAuthUser>
    patientEnrollmentProgramAuthUserStream() =>
        patientEnrollmentProgramAuthUserSubject
            .asBroadcastStream()
            .map((user) => currentUser = user);
