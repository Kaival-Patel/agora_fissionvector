import 'package:agora_fissionvector/modules/call/user_model.dart';
import 'package:get/get.dart';

class UserDmConstants {
  UserDmConstants._();

  static final UserDmConstants instance = UserDmConstants._();

  Rx<UserDm> defaultUserDm =
      UserDm(agoraUID: 11, name: 'Heerenbhai', userType: UserType.student).obs;

  List<UserDm> getUsersList() {
    return [
      UserDm(agoraUID: 11, name: 'Heerenbhai', userType: UserType.student),
      UserDm(agoraUID: 22, name: 'Deepika Singh', userType: UserType.tutor),
      UserDm(agoraUID: 33, name: 'Roma Malaika', userType: UserType.tutor),
      UserDm(agoraUID: 44, name: 'Shweta Jain', userType: UserType.tutor),
      UserDm(agoraUID: 55, name: 'Rupali Pandya', userType: UserType.tutor),
      UserDm(agoraUID: 66, name: 'Ishani Rawal', userType: UserType.tutor),
      UserDm(agoraUID: 77, name: 'Rina Parmar', userType: UserType.tutor),
    ];
  }
}
