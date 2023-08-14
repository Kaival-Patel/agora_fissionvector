import 'package:agora_fissionvector/modules/call/users_list.dart';
import 'package:agora_fissionvector/utils/user_dm_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select your user type'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
                onPressed: () {
                  UserDmConstants.instance.defaultUserDm(
                      UserDmConstants.instance.getUsersList().first);
                  Get.to(UsersList());
                },
                child: const Text('Continue as student')),
            OutlinedButton(
                onPressed: () {
                  UserDmConstants.instance.defaultUserDm(
                      UserDmConstants.instance.getUsersList().last);
                  Get.to(UsersList());
                },
                child: const Text('Continue as tutor')),
          ],
        ),
      ),
    );
  }
}
