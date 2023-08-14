import 'dart:async';

import 'package:agora_fissionvector/modules/agora_model.dart';
import 'package:agora_fissionvector/modules/call/user_model.dart';
import 'package:agora_fissionvector/utils/helpers.dart';
import 'package:agora_fissionvector/utils/string_constants.dart';
import 'package:agora_fissionvector/utils/user_dm_constants.dart';
import 'package:agora_rtc_engine/rtc_channel.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class UsersListController extends GetxController {
  RxBool myAvailability = false.obs;
  late RtcEngine _engine;
  var myUser = UserDmConstants.instance.defaultUserDm;
  RxList<UserDm> tutorsList = UserDmConstants.instance.getUsersList().obs;
  Rx<Key> listKey = UniqueKey().obs;
  Rx<AgoraResDm> agoraSettings = AgoraResDm().obs;
  RxBool isLoading = false.obs;

  List<UserDm> get displayTutorsList => tutorsList
      .where((element) => element.agoraUID != myUser().agoraUID)
      .toList();

  @override
  void onInit() {
    super.onInit();
    _initAgoraRTC();
  }

  void pauseApp() async {
    if (myUser().isOnline) {
      leaveMainChannel();
    }
  }

  void resumeApp() {
    if (myAvailability()) {
      joinMainChannel();
    }
  }

  @override
  void dispose() {
    _disposeListeners();
    super.dispose();
  }

  void _disposeListeners() {
    pauseApp();
  }

  void setAvailability({required bool isAvailable}) async {
    // TODO(Hiren): API call for availability for syncing up with backend
    if (isAvailable) {
      joinMainChannel();
    } else {
      leaveMainChannel();
    }
  }

  void _initAgoraRTC() async {
    isLoading(true);
    try {
      agoraSettings(await getAgoraTempToken(
        channelId: StringConstants.mainChannelId,
        uid: myUser().agoraUID,
      ));
      _engine = await RtcEngine.create(agoraSettings().appId);
      _addAgoraEventHandlers();
      await _engine.setChannelProfile(ChannelProfile.Communication);
      await _engine.disableVideo();
      await _engine.disableAudio();
      if (myUser().userType == UserType.student) {
        joinMainChannel();
      }
    } catch (e) {
      debugPrint("Error initing engine : $e");
    }
    isLoading(false);
  }

  void joinMainChannel() async {
    try {
      debugPrint('Attempting to join with ID: ${myUser().agoraUID}');
      await _engine.joinChannel(
        agoraSettings().token,
        agoraSettings().channelId,
        null,
        myUser().agoraUID,
      );
    } catch (e) {
      myUser().isOnline = false;
      myAvailability(false);
      if (e is PlatformException && e.code == '-17') {
        leaveMainChannel();
        Fluttertoast.showToast(msg: 'Try again');
      }
      debugPrint("Error joining : ${e} ${e.runtimeType}");
    }
  }

  void leaveMainChannel() async {
    await _engine.leaveChannel();
  }

  void changeUser(UserDm userDm) async {
    if (myUser().isOnline) {
      leaveMainChannel();
    }
    isLoading(true);
    try {
      myUser(userDm);
      myUser().isOnline = false;
      myAvailability(false);
      agoraSettings(await getAgoraTempToken(
        channelId: StringConstants.mainChannelId,
        uid: myUser().agoraUID,
      ));
    } catch (e) {
      debugPrint('$e');
    }
    isLoading(false);
  }

  void _addAgoraEventHandlers() {
    /// API CALL INCASE OF TUTOR ONLY
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        debugPrint('Error UserList:$code');
        Fluttertoast.showToast(msg: 'Event error:$code');
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        // TODO(Hiren): API call for availability of user joined for syncing up with backend
        debugPrint('Channel Joined Success : $uid');
        myUser().isOnline = true;
        myAvailability(true);
        Fluttertoast.showToast(msg: 'You are online');
      },
      tokenPrivilegeWillExpire: (token) async {
        await _engine.renewToken(token);
      },
      leaveChannel: (stats) {
        // TODO(Hiren): API call for availability of user left for syncing up with backend
        debugPrint('Channel Leave Success');
        myUser().isOnline = false;
        myAvailability(false);
        Fluttertoast.showToast(msg: 'You are offline');
      },
      userJoined: (uid, elapsed) {
        // TODO(Hiren): API call for availability of user joined for syncing up with backend
        debugPrint('User Joined : $uid');
        final tutor =
            tutorsList.firstWhereOrNull((element) => element.agoraUID == uid);
        listKey(UniqueKey());
        if (tutor != null) {
          tutor.isOnline = true;
          Fluttertoast.showToast(msg: '${tutor.name} is online');
        }
      },
      userOffline: (uid, reason) {
        // TODO(Hiren): API call for availability of user offline for syncing up with backend
        debugPrint('User Offline:$uid');
        final tutor =
            tutorsList.firstWhereOrNull((element) => element.agoraUID == uid);
        listKey(UniqueKey());
        if (tutor != null) {
          tutor.isOnline = false;
          Fluttertoast.showToast(msg: '${tutor.name} is offline');
        }
      },
    ));
  }
}
