// User information model class for storing user data in a structured way
class UserInfo {
  final String firstName;
  final String lastName;
  final String type;
  final String email;

  UserInfo({
    required this.firstName,
    required this.lastName,
    required this.type,
    required this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      type: json['type'] ?? '',
      email: json['email'] ?? '',
    );
  }

  String get fullName => '$firstName $lastName';

  @override
  String toString() {
    return '$fullName ($type)';
  }
}
