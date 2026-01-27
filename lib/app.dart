import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/navigation_menu.dart';
import 'package:karang_taruna/screens/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: session != null ? const NavigationMenu() : const LoginScreen(),
    );
  }
}
