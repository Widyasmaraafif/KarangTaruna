import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/buttons/profile_menu_tile.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:karang_taruna/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = SupabaseService();
  String _name = 'User';
  String _role = 'Anggota Karang Taruna';
  String _avatarUrl = 'https://ui-avatars.com/api/?name=User&background=random';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _service.currentUser;
      if (user != null) {
        setState(() {
          _name =
              user.userMetadata?['full_name'] ??
              user.email?.split('@')[0] ??
              'User';
          _avatarUrl =
              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_name)}&background=random';
        });

        // Try to fetch from profiles table if needed
        final profile = await _service.getCurrentUserProfile();
        if (profile != null) {
          setState(() {
            if (profile['full_name'] != null) _name = profile['full_name'];
            if (profile['role'] != null) _role = profile['role'];
            if (profile['avatar_url'] != null &&
                profile['avatar_url'].toString().isNotEmpty) {
              _avatarUrl = profile['avatar_url'];
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> _logout() async {
    try {
      await _service.signOut();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      Get.snackbar('Error', 'Gagal keluar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          image: DecorationImage(
                            image: NetworkImage(_avatarUrl),
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
                              _name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _role,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF00BA9B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // White Container Section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Akun'),
                      KTProfileMenuTile(
                        icon: Icons.person_outline,
                        title: 'Info Personal',
                        subtitle: 'Nama, Email, Nomor HP',
                        onTap: () {},
                      ),
                      const SizedBox(height: 8),
                      KTProfileMenuTile(
                        icon: Icons.lock_outline,
                        title: 'Keamanan',
                        subtitle: 'Ubah kata sandi',
                        onTap: () {},
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Umum'),
                      KTProfileMenuTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notifikasi',
                        onTap: () {},
                      ),
                      const SizedBox(height: 8),
                      KTProfileMenuTile(
                        icon: Icons.language,
                        title: 'Bahasa',
                        subtitle: 'Indonesia',
                        onTap: () {},
                      ),
                      const SizedBox(height: 8),
                      KTProfileMenuTile(
                        icon: Icons.help_outline,
                        title: 'Bantuan & Dukungan',
                        onTap: () {},
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Lainnya'),
                      KTProfileMenuTile(
                        icon: Icons.info_outline,
                        title: 'Tentang Aplikasi',
                        onTap: () {},
                      ),
                      const SizedBox(height: 8),
                      KTProfileMenuTile(
                        icon: Icons.logout,
                        title: 'Keluar',
                        isDestructive: true,
                        showTrailing: false,
                        onTap: _logout,
                      ),
                      const SizedBox(height: 20), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
