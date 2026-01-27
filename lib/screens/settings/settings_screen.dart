import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/screens/profile/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reuse ProfileScreen for now as it contains settings-like items
    return const ProfileScreen(); 
  }
}
