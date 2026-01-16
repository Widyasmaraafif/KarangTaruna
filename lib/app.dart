import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/navigation_menu.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const NavigationMenu(),
    );
  }
}
