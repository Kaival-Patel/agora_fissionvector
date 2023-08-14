import 'package:agora_fissionvector/modules/call/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum CallState { outgoing, incoming, connected, idle }

class AudioCall extends StatelessWidget {
  final UserDm opponentUserDm;
  final bool isSpeakerEnabled;
  final bool isMicEnabled;
  final void Function()? onSpeakerToggle;
  final void Function()? onCallHang;
  final void Function()? onCallPick;
  final void Function()? onMicToggle;
  final CallState callState;

  const AudioCall(
      {Key? key,
      required this.opponentUserDm,
      required this.isSpeakerEnabled,
      required this.isMicEnabled,
      this.onCallHang,
      this.onCallPick,
      this.onMicToggle,
      this.onSpeakerToggle,
      this.callState = CallState.connected})
      : super(key: key);

  String get connectionStatus {
    switch (callState) {
      case CallState.outgoing:
        return 'Audio call waiting for ${opponentUserDm.name} to join';
      case CallState.incoming:
        return 'Incoming audio call from ${opponentUserDm.name}';
      case CallState.connected:
        return 'Audio call connected with ${opponentUserDm.name}';
      case CallState.idle:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[100],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.amber,
              radius: 50,
              child: Text(
                opponentUserDm.name.substring(0, 1),
                style: context.textTheme.displaySmall,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              connectionStatus,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (callState == CallState.connected) ...[
                  RawMaterialButton(
                      shape: const CircleBorder(),
                      onPressed: onSpeakerToggle,
                      padding: const EdgeInsets.all(10),
                      fillColor:
                          isSpeakerEnabled ? Colors.white : Colors.grey[700],
                      child: Icon(
                        Icons.volume_up,
                        color: isSpeakerEnabled ? Colors.black : Colors.white,
                      )),
                  RawMaterialButton(
                      shape: const CircleBorder(),
                      onPressed: onCallHang,
                      padding: const EdgeInsets.all(30),
                      fillColor: Colors.red[700],
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                      )),
                  RawMaterialButton(
                    shape: const CircleBorder(),
                    onPressed: onMicToggle,
                    padding: const EdgeInsets.all(10),
                    fillColor: isMicEnabled ? Colors.white : Colors.grey[700],
                    child: Icon(
                      isMicEnabled ? Icons.mic : Icons.mic_off,
                      color: isMicEnabled ? Colors.black : Colors.white,
                    ),
                  ),
                ] else if (callState == CallState.outgoing) ...[
                  RawMaterialButton(
                      shape: const CircleBorder(),
                      onPressed: onCallHang,
                      padding: const EdgeInsets.all(30),
                      fillColor: Colors.red[700],
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  RawMaterialButton(
                      shape: const CircleBorder(),
                      onPressed: onMicToggle,
                      padding: const EdgeInsets.all(10),
                      fillColor: isMicEnabled ? Colors.white : Colors.grey[700],
                      child: Icon(
                        isMicEnabled ? Icons.mic : Icons.mic_off,
                        color: isMicEnabled ? Colors.black : Colors.white,
                      )),
                ] else ...[
                  RawMaterialButton(
                      shape: const CircleBorder(),
                      onPressed: onCallPick,
                      padding: const EdgeInsets.all(30),
                      fillColor: Colors.green[700],
                      child: const Icon(
                        Icons.call,
                        color: Colors.white,
                        size: 40,
                      )),
                  const SizedBox(
                    width: 30,
                  ),
                  RawMaterialButton(
                      shape: const CircleBorder(),
                      onPressed: onCallHang,
                      padding: const EdgeInsets.all(30),
                      fillColor: Colors.red[700],
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 40,
                      )),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}
