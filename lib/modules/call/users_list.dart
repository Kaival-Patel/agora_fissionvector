import 'package:agora_fissionvector/modules/call/audio_call/audio_call.dart';
import 'package:agora_fissionvector/modules/call/chat/chat.dart';
import 'package:agora_fissionvector/modules/call/user_model.dart';
import 'package:agora_fissionvector/modules/call/users_list_controller.dart';
import 'package:agora_fissionvector/utils/user_dm_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UsersList extends StatefulWidget {
  UsersList({Key? key}) : super(key: key);

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> with WidgetsBindingObserver {
  final c = Get.put(UsersListController());

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        c.resumeApp();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        c.pauseApp();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutors'),
        actions: [
          Obx(
            () => Visibility(
              visible: c.myUser().userType == UserType.tutor,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.myAvailability() ? 'Online' : 'Offline'),
                  CupertinoSwitch(
                    value: c.myAvailability(),
                    onChanged: (v) {
                      c.myAvailability(v);
                      c.setAvailability(isAvailable: v);
                    },
                  )
                ],
              ),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            color: Colors.grey[100],
            child: Obx(() => Center(
                  child: TextButton(
                    child: Text(
                        'You are ${c.myUser().name} and Agora ID : ${c.myUser().agoraUID} (Tap to change)'),
                    onPressed: () {
                      Get.bottomSheet(UserChangeDialog());
                    },
                  ),
                )),
          ),
        ),
      ),
      body: Obx(() => c.isLoading()
          ? const Center(
              child: CupertinoActivityIndicator(),
            )
          : Obx(
              () => ListView.builder(
                  key: c.listKey(),
                  itemBuilder: (context, index) => ListTile(
                        onTap: () async {
                          c.leaveMainChannel();
                          await Get.to(() => ChatScreen(
                              currentUserDm: c.myUser(),
                              oppenentUserDm: c.displayTutorsList[index]));
                          c.setAvailability(isAvailable: c.myAvailability());
                        },
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(c.displayTutorsList[index].name),
                            const SizedBox(
                              width: 20,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 5),
                              decoration: BoxDecoration(
                                  color: c.displayTutorsList[index].isOnline
                                      ? Colors.green[700]
                                      : Colors.grey[600],
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(
                                c.displayTutorsList[index].isOnline
                                    ? "ONLINE"
                                    : "OFFLINE",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(c.displayTutorsList[index].userType.name
                                .capitalizeFirst ??
                            ''),
                      ),
                  itemCount: c.displayTutorsList.length),
            )),
    );
  }
}

class UserChangeDialog extends StatelessWidget {
  UserChangeDialog({Key? key}) : super(key: key);
  final c = Get.find<UsersListController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.amber[200],
      ),
      padding: const EdgeInsets.all(10),
      child: Obx(() => ListView.builder(
          itemBuilder: (context, index) => ListTile(
                onTap: () {
                  c.changeUser(c.displayTutorsList[index]);
                  Get.back();
                },
                title: Text(c.displayTutorsList[index].name),
                subtitle: Text(
                    c.displayTutorsList[index].userType.name.capitalizeFirst ??
                        '' ' (Tap to change)'),
              ),
          itemCount: c.displayTutorsList.length)),
    );
  }
}
