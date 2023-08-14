import 'dart:convert';
import 'dart:typed_data';

import 'package:agora_fissionvector/modules/agora_model.dart';
import 'package:agora_fissionvector/modules/call/audio_call/audio_call.dart';
import 'package:agora_fissionvector/modules/call/chat/model/chat_model.dart';
import 'package:agora_fissionvector/modules/call/user_model.dart';
import 'package:agora_fissionvector/utils/helpers.dart';
import 'package:agora_fissionvector/utils/string_constants.dart';
import 'package:agora_fissionvector/utils/user_dm_constants.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

enum ConnectionType { chat, audio, video }

class ChatController extends GetxController {
  UserDm oppenentUserDm;
  UserDm currentUserDm;

  ChatController({
    required this.oppenentUserDm,
    required this.currentUserDm,
  });

  late String channelId;
  late int _dataStreamId;
  late RtcEngine _engine;
  RxList<ChatDm> channelChats = <ChatDm>[].obs;
  TextEditingController chatController = TextEditingController();
  RxBool isLoading = false.obs;
  Rx<ConnectionType> connectionType = ConnectionType.chat.obs;
  Rx<AgoraResDm> agoraSettings = AgoraResDm().obs;
  RxBool isOpponentUserDmEnabledAudio = false.obs;
  RxBool isCurrentUserDmEnabledAudio = false.obs;
  RxBool isOpponentUserDmEnabledVideo = false.obs;
  RxBool isCurrentUserDmEnabledVideo = false.obs;
  RxBool isSpeakerEnabled = false.obs;
  RxBool isMicEnabled = false.obs;
  RxBool isHangOrDisabledAudio = false.obs;
  RxBool isAudioCall = false.obs;

  CallState get callState {
    return isAudioCall() ? audioCallState : videoCallState;
  }

  CallState get audioCallState {
    if (isHangOrDisabledAudio()) {
      return CallState.idle;
    } else if (isCurrentUserDmEnabledAudio() &&
        !isOpponentUserDmEnabledAudio()) {
      return CallState.outgoing;
    } else if (isCurrentUserDmEnabledAudio() &&
        isOpponentUserDmEnabledAudio()) {
      return CallState.connected;
    } else if (!isCurrentUserDmEnabledAudio() &&
        isOpponentUserDmEnabledAudio()) {
      return CallState.incoming;
    }
    return CallState.idle;
  }

  CallState get videoCallState {
    if (isHangOrDisabledAudio()) {
      return CallState.idle;
    } else if (isCurrentUserDmEnabledVideo() &&
        !isOpponentUserDmEnabledVideo()) {
      return CallState.outgoing;
    } else if (isCurrentUserDmEnabledVideo() &&
        isOpponentUserDmEnabledVideo()) {
      return CallState.connected;
    } else if (!isCurrentUserDmEnabledVideo() &&
        isOpponentUserDmEnabledVideo()) {
      return CallState.incoming;
    }
    return CallState.idle;
  }

  @override
  void onInit() {
    _generateUniqueId();
    _initAgoraRTC();
    super.onInit();
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  void _generateUniqueId() {
    final studentUser =
        oppenentUserDm.isStudent ? oppenentUserDm : currentUserDm;
    final tutorUser =
        !oppenentUserDm.isStudent ? oppenentUserDm : currentUserDm;
    channelId = 'chat_${studentUser.agoraUID}_${tutorUser.agoraUID}';
  }

  void _initAgoraRTC() async {
    isLoading(true);
    try {
      final agoraAPICall = await getAgoraTempToken(
        channelId: channelId,
        uid: currentUserDm.agoraUID,
      );
      if (agoraAPICall.isSuccess) {
        agoraSettings(
          await getAgoraTempToken(
            channelId: channelId,
            uid: currentUserDm.agoraUID,
          ),
        );
        Fluttertoast.showToast(msg: 'Connecting, please wait');
      } else {
        agoraSettings().token = StringConstants.tokens[channelId]!;
      }
      _engine = await RtcEngine.create(StringConstants.agoraAppId);
      _addAgoraEventHandlers();
      await _engine.setChannelProfile(ChannelProfile.Communication);
      await _engine.disableVideo();
      await _engine.disableAudio();
      joinChatChannel();
    } catch (e) {
      debugPrint("Error initing engine : $e");
    }
    isLoading(false);
  }

  void joinChatChannel() async {
    try {
      debugPrint('Trying to join : $channelId');
      await _engine.joinChannel(
        agoraSettings().token,
        channelId,
        null,
        currentUserDm.agoraUID,
      );
      _dataStreamId = await _engine.createDataStream(true, true) ?? 0;
    } catch (e) {
      if (e is PlatformException && e.code == '-17') {
        _engine.leaveChannel();
        Fluttertoast.showToast(msg: 'Try again');
      }
    }
  }

  void _addAgoraEventHandlers() {
    /// API CALL INCASE OF TUTOR ONLY
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        debugPrint('Error:$code');
        Fluttertoast.showToast(msg: 'Event error:$code');
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        debugPrint('Channel Joined Success : $uid');
        Fluttertoast.showToast(msg: 'Joined chat');
      },
      tokenPrivilegeWillExpire: (token) async {
        await _engine.renewToken(token);
      },
      leaveChannel: (stats) {
        debugPrint('Channel Leave Success');
        Fluttertoast.showToast(msg: 'Left chat');
      },
      userJoined: (uid, elapsed) {
        debugPrint('User Joined : $uid');
        Fluttertoast.showToast(msg: '${oppenentUserDm.name} joined the chat');
      },
      userOffline: (uid, reason) {
        debugPrint('User Offline:$uid');
        Fluttertoast.showToast(msg: '${oppenentUserDm.name} left the chat');
      },
      streamMessage: (uid, streamId, data) {
        debugPrint('Message Received : $data');
      },
      localAudioStateChanged: (state, error) {
        debugPrint('RTC -> Local audio state changed for $state');
        if (state == AudioLocalState.Stopped) {
          isCurrentUserDmEnabledAudio(false);
        } else {
          isCurrentUserDmEnabledAudio(true);
        }
      },
      firstRemoteAudioFrame: (uid, elapsed) {
        debugPrint('RTC -> Remote audio firstRemoteAudioFrame for $uid');
      },
      remoteAudioTransportStats: (uid, delay, lost, rxKBitRate) {
        debugPrint('RTC -> Remote audio remoteAudioTransportStats for $uid');
      },
      userMuteAudio: (uid, muted) {
        debugPrint('RTC -> User $muted muted audio for $uid');
      },
      userEnableLocalVideo: (uid, enabled) {
        debugPrint(
            'RTC -> Remote video state changed for $uid and oppenent uid ');
        if (uid == oppenentUserDm.agoraUID) {
          isOpponentUserDmEnabledVideo(enabled);
        }
        if (uid == currentUserDm.agoraUID) {
          isCurrentUserDmEnabledVideo(enabled);
        }
      },
      localVideoStateChanged: (localVideoState, error) {
        if (localVideoState == LocalVideoStreamState.Capturing ||
            localVideoState == LocalVideoStreamState.Encoding) {
          isAudioCall(false);
        } else {}
      },
      remoteVideoStateChanged: (uid, state, reason, elapsed) {
        debugPrint(
            'RTC -> Remote video state changed for $uid and oppenent uid '
            ':${oppenentUserDm.agoraUID} remote state:${state}');
      },
      remoteAudioStateChanged: (uid, state, reason, elapsed) {
        debugPrint(
            'RTC -> Remote audio state changed for $uid and oppenent uid '
            ':${oppenentUserDm.agoraUID} remote state:${state}');
        if (uid == oppenentUserDm.agoraUID) {
          if (state == AudioRemoteState.Starting) {
            isOpponentUserDmEnabledAudio(true);
          } else {
            isOpponentUserDmEnabledAudio(false);
          }
        }
      },
    ));
  }

  void sendMessage(String message) async {
    debugPrint('DataStream Id: $_dataStreamId');
    final messageInBytes = Uint8List.fromList(utf8.encode(message));
    await _engine.sendStreamMessage(
      _dataStreamId,
      Uint8List(0),
    );
  }

  void enableAudio() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.camera,
    ].request();
    await _engine.enableAudio();
    await _engine.setAudioProfile(
        AudioProfile.SpeechStandard, AudioScenario.ChatRoomEntertainment);
    await _engine.muteLocalAudioStream(false);
    isMicEnabled(true);
  }

  void disableAudio() async {
    await _engine.disableAudio();
  }

  void disableVideo() async {
    await _engine.disableVideo();
  }

  void enableVideo() async {
    isCurrentUserDmEnabledVideo(true);
    await _engine.enableVideo();
  }

  void toggleSpeaker() async {
    debugPrint('Toggling Speaker');
    isSpeakerEnabled(!isSpeakerEnabled());
    await _engine.setEnableSpeakerphone(isSpeakerEnabled());
  }

  void toggleMic() async {
    debugPrint('Toggling Mic');
    isMicEnabled(!isMicEnabled());
    await _engine.muteLocalAudioStream(isMicEnabled());
  }
}
