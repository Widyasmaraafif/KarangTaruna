import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/screens/admin/manage_members_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pengaturan Admin',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminMenuTile(
            icon: Icons.people_outline,
            title: 'Kelola Anggota',
            subtitle: 'Verifikasi dan kelola data anggota',
            onTap: () => Get.to(() => const ManageMembersScreen()),
          ),
          _buildAdminMenuTile(
            icon: Icons.event_note,
            title: 'Kelola Kegiatan',
            subtitle: 'Tambah dan edit kegiatan Karang Taruna',
            onTap: () {
              // TODO: Navigate to event management
              Get.snackbar('Info', 'Fitur Kelola Kegiatan akan segera hadir');
            },
          ),
          _buildAdminMenuTile(
            icon: Icons.article_outlined,
            title: 'Kelola Berita',
            subtitle: 'Publikasi berita dan informasi',
            onTap: () {
              // TODO: Navigate to news management
              Get.snackbar('Info', 'Fitur Kelola Berita akan segera hadir');
            },
          ),
          _buildAdminMenuTile(
            icon: Icons.monetization_on_outlined,
            title: 'Kelola Keuangan',
            subtitle: 'Catat pemasukan dan pengeluaran',
            onTap: () {
              // TODO: Navigate to finance management
              Get.snackbar('Info', 'Fitur Kelola Keuangan akan segera hadir');
            },
          ),
          _buildAdminMenuTile(
            icon: Icons.poll_outlined,
            title: 'Kelola Polling',
            subtitle: 'Buat dan pantau pemungutan suara',
            onTap: () {
              // TODO: Navigate to poll management
              Get.snackbar('Info', 'Fitur Kelola Polling akan segera hadir');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF00BA9B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF00BA9B)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
