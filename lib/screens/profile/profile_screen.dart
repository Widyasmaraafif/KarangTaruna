import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/buttons/profile_menu_tile.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:karang_taruna/screens/auth/login_screen.dart';

import 'package:karang_taruna/screens/profile/personal_data_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout() async {
    try {
      await SupabaseService().signOut();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      Get.snackbar('Error', 'Gagal keluar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();

    return Scaffold(
      backgroundColor: const Color(0xFF00BA9B),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pengaturan Akun',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Keluar',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Profile Summary
                  Obx(() {
                    final profile = controller.userProfile;
                    final name = profile['full_name'] ?? 'User';
                    final role = profile['role'] ?? 'Anggota Karang Taruna';
                    final avatarUrl =
                        profile['avatar_url'] ??
                        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random';

                    return Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: DecorationImage(
                              image: NetworkImage(avatarUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                role,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Trigger refresh manually if needed
                            controller.fetchUserProfile();
                            Get.snackbar(
                              'Info',
                              'Memperbarui profil...',
                              duration: const Duration(seconds: 1),
                            );
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            // Content Section
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Text(
                      'Akun',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    KTProfileMenuTile(
                      icon: Icons.person_outline,
                      title: 'Data Diri',
                      onTap: () => Get.to(() => const PersonalDataScreen()),
                    ),
                    KTProfileMenuTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifikasi',
                      onTap: () {},
                    ),
                    KTProfileMenuTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privasi',
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Lainnya',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    KTProfileMenuTile(
                      icon: Icons.help_outline,
                      title: 'Bantuan',
                      onTap: () {},
                    ),
                    KTProfileMenuTile(
                      icon: Icons.info_outline,
                      title: 'Tentang Aplikasi',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
