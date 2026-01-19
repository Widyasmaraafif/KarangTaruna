import 'package:flutter/material.dart';
import 'package:karang_taruna/commons/widgets/buttons/profile_menu_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
                        onPressed: () {},
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
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://ui-avatars.com/api/?name=Ahmad+Fulan&background=random',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ahmad Fulan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Anggota Karang Taruna',
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
                        onTap: () {},
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
