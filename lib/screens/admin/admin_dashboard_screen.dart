import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/screens/admin/manage_announcements_screen.dart';
import 'package:karang_taruna/screens/admin/manage_events_screen.dart';
import 'package:karang_taruna/screens/admin/manage_finance_screen.dart';
import 'package:karang_taruna/screens/admin/manage_gallery_screen.dart';
import 'package:karang_taruna/screens/admin/manage_members_screen.dart';
import 'package:karang_taruna/screens/admin/manage_news_screen.dart';
import 'package:karang_taruna/screens/admin/manage_organization_finance_screen.dart';
import 'package:karang_taruna/screens/admin/manage_pojok_kampung_screen.dart';
import 'package:karang_taruna/screens/admin/manage_polling_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DataController dataController = Get.find<DataController>();
    final role =
        dataController.userProfile['role']?.toString().toLowerCase() ?? '';

    // Logic for role-based access
    bool canAccess(String feature) {
      if (role == 'admin') return true;

      // bendahara: hanya kelola keuangan (iuran dan organisasi)
      if (role == 'bendahara' && ['finance', 'finance_org'].contains(feature)) {
        return true;
      }

      // ketua: kelola pengumuman, kegiatan, pojok kampung, polling
      if (role == 'ketua' &&
          [
            'announcements',
            'events',
            'pojok_kampung',
            'polling',
          ].contains(feature)) {
        return true;
      }

      // sekretaris: kelola pengumuman dan kegiatan
      if (role == 'sekretaris' &&
          ['announcements', 'events'].contains(feature)) {
        return true;
      }

      // pubdekdok: kelola berita dan kelola galeri
      if (role == 'pubdekdok' && ['news', 'gallery'].contains(feature)) {
        return true;
      }

      return false;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          role == 'admin' ? 'Pengaturan Admin' : 'Menu Pengurus',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
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
          if (canAccess('members'))
            _buildAdminMenuTile(
              icon: Icons.people_outline,
              title: 'Kelola Anggota',
              subtitle: 'Verifikasi dan kelola data anggota',
              onTap: () => Get.to(() => const ManageMembersScreen()),
            ),
          if (canAccess('events'))
            _buildAdminMenuTile(
              icon: Icons.event_note,
              title: 'Kelola Kegiatan',
              subtitle: 'Tambah dan edit kegiatan Karang Taruna',
              onTap: () => Get.to(() => const ManageEventsScreen()),
            ),
          if (canAccess('news'))
            _buildAdminMenuTile(
              icon: Icons.article_outlined,
              title: 'Kelola Berita',
              subtitle: 'Publikasi berita dan informasi',
              onTap: () => Get.to(() => const ManageNewsScreen()),
            ),
          if (canAccess('announcements'))
            _buildAdminMenuTile(
              icon: Icons.campaign_outlined,
              title: 'Kelola Pengumuman',
              subtitle: 'Buat dan atur pengumuman penting',
              onTap: () => Get.to(() => const ManageAnnouncementsScreen()),
            ),
          if (canAccess('pojok_kampung'))
            _buildAdminMenuTile(
              icon: Icons.storefront_outlined,
              title: 'Kelola Pojok Kampung',
              subtitle: 'Atur aspirasi dan galeri kampung',
              onTap: () => Get.to(() => const ManagePojokKampungScreen()),
            ),
          if (canAccess('gallery'))
            _buildAdminMenuTile(
              icon: Icons.photo_library_outlined,
              title: 'Kelola Galeri',
              subtitle: 'Upload dan atur foto kegiatan',
              onTap: () => Get.to(() => const ManageGalleryScreen()),
            ),
          if (canAccess('finance'))
            _buildAdminMenuTile(
              icon: Icons.monetization_on_outlined,
              title: 'Kelola Iuran Anggota',
              subtitle: 'Manajemen iuran bulanan anggota',
              onTap: () => Get.to(() => const ManageFinanceScreen()),
            ),
          if (canAccess('finance_org'))
            _buildAdminMenuTile(
              icon: Icons.account_balance_outlined,
              title: 'Kelola Keuangan Organisasi',
              subtitle: 'Manajemen kas dan transaksi organisasi',
              onTap: () =>
                  Get.to(() => const ManageOrganizationFinanceScreen()),
            ),
          if (canAccess('polling'))
            _buildAdminMenuTile(
              icon: Icons.poll_outlined,
              title: 'Kelola Polling',
              subtitle: 'Buat dan pantau pemungutan suara',
              onTap: () => Get.to(() => const ManagePollingScreen()),
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
