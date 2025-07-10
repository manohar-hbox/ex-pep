import 'package:collection/collection.dart';

enum PESScreenType {
  PatientList,
  FollowUpList,
  DeferredList,
}

enum CSScreenType {
  PatientList,
  TransferredList,
  DeferredList,
  FollowUpList,
}

enum OriginNumberType {
  Enrollment,
}

extension FFEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension FFEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  switch (T) {
    case (PESScreenType):
      return PESScreenType.values.deserialize(value) as T?;
    case (CSScreenType):
      return CSScreenType.values.deserialize(value) as T?;
    case (OriginNumberType):
      return OriginNumberType.values.deserialize(value) as T?;
    default:
      return null;
  }
}
