enum UserType { student, tutor }

class UserDm {
  int agoraUID;
  String name;
  UserType userType;
  bool isOnline;

  bool get isStudent => userType == UserType.student;

  UserDm({
    required this.agoraUID,
    required this.name,
    required this.userType,
    this.isOnline = false,
  });
}
