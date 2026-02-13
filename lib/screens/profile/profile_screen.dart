import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';
import 'package:karang_taruna/commons/widgets/alert_dialog.dart';
import 'package:karang_taruna/commons/widgets/buttons/profile_menu_tile.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/screens/admin/admin_dashboard_screen.dart';
import 'package:karang_taruna/screens/profile/about_app_screen.dart';
import 'package:karang_taruna/screens/profile/help_screen.dart';
import 'package:karang_taruna/screens/profile/notification_settings_screen.dart';
import 'package:karang_taruna/screens/profile/privacy_settings_screen.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:karang_taruna/screens/auth/login_screen.dart';

import 'package:karang_taruna/screens/profile/personal_data_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout() async {
    try {
      KTAlertDialog.show(
        Get.context!,
        title: 'Keluar Akun',
        content: 'Apakah Anda yakin ingin keluar dari aplikasi?',
        confirmText: 'Keluar',
        confirmColor: KTColor.error,
        onConfirm: () async {
          final controller = Get.find<DataController>();
          controller.clearData();
          await SupabaseService().signOut();
          Get.offAll(() => const LoginScreen());
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal keluar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();

    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text(
          "Pengaturan Akun",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: KTColor.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, size: 20),
            color: KTColor.error,
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profile Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Obx(() {
                final profile = controller.userProfile;
                final name = profile['full_name'] ?? 'User';
                final role = profile['role'] ?? 'Anggota Karang Taruna';
                final avatarUrl =
                    profile['avatar_url'] ??
                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random';

                return Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: KTColor.primary.withOpacity(0.1),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: KTColor.shadow.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(avatarUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: KTColor.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: KTColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        role.toString().toUpperCase(),
                        style: const TextStyle(
                          color: KTColor.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informasi Pribadi",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: KTColor.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  KTProfileMenuTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Data Pribadi',
                    onTap: () => Get.to(() => const PersonalDataScreen()),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "Keamanan & Pengaturan",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: KTColor.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  KTProfileMenuTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifikasi',
                    onTap: () =>
                        Get.to(() => const NotificationSettingsScreen()),
                  ),
                  KTProfileMenuTile(
                    icon: Icons.security_rounded,
                    title: 'Privasi',
                    onTap: () => Get.to(() => const PrivacySettingsScreen()),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "Lainnya",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: KTColor.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  KTProfileMenuTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Bantuan',
                    onTap: () => Get.to(() => const HelpScreen()),
                  ),
                  KTProfileMenuTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Aplikasi',
                    onTap: () => Get.to(() => const AboutAppScreen()),
                  ),

                  // Admin Menu (Conditional)
                  Obx(() {
                    if (controller.userProfile['role'] == 'admin') {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          const Text(
                            "Administrator",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: KTColor.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          KTProfileMenuTile(
                            icon: Icons.admin_panel_settings_outlined,
                            title: 'Dashboard Admin',
                            onTap: () =>
                                Get.to(() => const AdminDashboardScreen()),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
