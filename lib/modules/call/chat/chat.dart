import 'package:agora_fissionvector/modules/call/audio_call/audio_call.dart';
import 'package:agora_fissionvector/modules/call/chat/chat_controller.dart';
import 'package:agora_fissionvector/modules/call/user_model.dart';
import 'package:agora_fissionvector/modules/call/video_call/video_call.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// TODO(Hiren): Redirect [student, tutor] to chat screen when they tap on call or chat notification
class ChatScreen extends StatelessWidget {
  ChatScreen(
      {Key? key, required UserDm currentUserDm, required UserDm oppenentUserDm})
      : super(key: key) {
    c = Get.put(ChatController(
        oppenentUserDm: oppenentUserDm, currentUserDm: currentUserDm));
  }

  late ChatController c;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (c.callState == CallState.idle) ...[
                Text(c.oppenentUserDm.name),
                Text(
                  c.oppenentUserDm.userType.name.capitalizeFirst ?? '',
                  style: context.textTheme.bodySmall,
                )
              ]
            ],
          ),
          actions: c.callState == CallState.idle && !c.isHangOrDisabledAudio()
              ? [
                  IconButton(
                      onPressed: () {
                        c.isAudioCall(true);
                        c.enableAudio();
                      },
                      icon: const Icon(Icons.phone)),
                  IconButton(
                      onPressed: () {
                        c.isAudioCall(false);
                        c.enableAudio();
                        c.enableVideo();
                        c.isCurrentUserDmEnabledVideo(true);
                      },
                      icon: const Icon(Icons.video_call)),
                ]
              : null,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              color: Colors.grey[100],
              height: 40,
              child: Obx(() =>
                  c.callState == CallState.idle && c.isHangOrDisabledAudio()
                      ? const Center(
                          child: Text('You have rejected/completed call now'),
                        )
                      : const Center(
                          child: Text('You can make audio/video call'),
                        )),
            ),
          ),
        ),
        body: Obx(
          () => c.isLoading()
              ? const Center(
                  child: CupertinoActivityIndicator(),
                )
              : c.callState != CallState.idle
                  ? c.isAudioCall()
                      ? Obx(
                          () => AudioCall(
                            opponentUserDm: c.oppenentUserDm,
                            isSpeakerEnabled: c.isSpeakerEnabled(),
                            isMicEnabled: c.isMicEnabled(),
                            callState: c.audioCallState,
                            onCallHang: () {
                              c.isHangOrDisabledAudio(true);
                              c.disableAudio();
                            },
                            onCallPick: () {
                              c.enableAudio();
                            },
                            onMicToggle: c.toggleMic,
                            onSpeakerToggle: c.toggleSpeaker,
                          ),
                        )
                      : Obx(
                          () => VideoCall(
                            opponentUserDm: c.oppenentUserDm,
                            isSpeakerEnabled: c.isSpeakerEnabled(),
                            isMicEnabled: c.isMicEnabled(),
                            callState: c.videoCallState,
                            channelId: c.channelId,
                            onCallHang: () {
                              c.isHangOrDisabledAudio(true);
                              c.disableAudio();
                              c.disableVideo();
                            },
                            onCallPick: () {
                              c.enableAudio();
                              c.enableVideo();
                            },
                            onMicToggle: c.toggleMic,
                            onSpeakerToggle: c.toggleSpeaker,
                          ),
                        )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Chat coming soon, you can video/audio call'),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
