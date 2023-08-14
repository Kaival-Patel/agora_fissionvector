import 'package:agora_fissionvector/modules/call/selection_module/selection_module.dart';
import 'package:agora_fissionvector/modules/call/users_list.dart';
import 'package:agora_fissionvector/utils/helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyBoard(context),
      child: Builder(builder: (context) {
        return GetMaterialApp(
          enableLog: kDebugMode,
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.light,
          theme: ThemeData(
              colorScheme: const ColorScheme.light(primary: Colors.amber)),
          title: 'Agora FissionVector',
          home: const SelectionScreen(),
        );
      }),
    );
  }
}
