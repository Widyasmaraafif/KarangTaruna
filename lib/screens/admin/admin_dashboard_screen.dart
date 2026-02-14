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
import 'package:karang_taruna/commons/styles/kt_color.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();
    final userRole =
        controller.userProfile['role']?.toString().toLowerCase() ?? '';

    bool canAccess(String permission) {
      if (userRole == 'admin') return true;
      final Map<String, Set<String>> rolePermissions = {
        'bendahara': {'finance', 'finance_org'},
        'ketua': {'announcements', 'events', 'pojok_kampung', 'polling'},
        'sekretaris': {'announcements', 'events'},
        'pubdekdok': {'news', 'gallery'},
      };
      final allowed = rolePermissions[userRole] ?? {};
      return allowed.contains(permission);
    }

    final hasContent =
        canAccess('news') ||
        canAccess('events') ||
        canAccess('announcements') ||
        canAccess('gallery');
    final hasFinance = canAccess('finance_org') || canAccess('finance');
    final hasOrg =
        canAccess('members') ||
        canAccess('polling') ||
        canAccess('pojok_kampung');

    final List<Widget> children = [];
    if (hasContent) {
      children.addAll([
        const Text(
          "Manajemen Konten",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: KTColor.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
      ]);
      if (canAccess('news')) {
        children.add(
          _buildAdminMenuTile(
            icon: Icons.article_rounded,
            title: 'Kelola Berita',
            subtitle: 'Publikasi berita dan informasi terbaru',
            onTap: () => Get.to(() => const ManageNewsScreen()),
          ),
        );
      }
      if (canAccess('events')) {
        children.add(
          _buildAdminMenuTile(
            icon: Icons.event_note_rounded,
            title: 'Kelola Kegiatan',
            subtitle: 'Atur jadwal dan detail kegiatan',
            onTap: () => Get.to(() => const ManageEventsScreen()),
          ),
        );
      }
      if (canAccess('announcements')) {
        children.add(
          _buildAdminMenuTile(
            icon: Icons.campaign_rounded,
            title: 'Kelola Pengumuman',
            subtitle: 'Buat pengumuman penting untuk warga',
            onTap: () => Get.to(() => const ManageAnnouncementsScreen()),
          ),
        );
      }
      if (canAccess('gallery')) {
        children.add(
          _buildAdminMenuTile(
            icon: Icons.photo_library_rounded,
            title: 'Kelola Galeri',
            subtitle: 'Upload foto-foto kegiatan',
            onTap: () => Get.to(() => const ManageGalleryScreen()),
          ),
        );
      }
    }

    if (hasFinance) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 32));
      }
      children.addAll([
        const Text(
          "Manajemen Keuangan",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: KTColor.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
      ]);
      if (canAccess('finance_org')) {
        children.add(
          _buildAdminMenuTile(
            icon: Icons.account_balance_rounded,
            title: 'Keuangan Organisasi',
            subtitle: 'Manajemen kas dan transaksi kas',
            onTap: () => Get.to(() => const ManageOrganizationFinanceScreen()),
          ),
        );
      }
      if (canAccess('finance')) {
        children.add(
          _buildAdminMenuTile(
            icon: Icons.monetization_on_rounded,
            title: 'Iuran Anggota',
            subtitle: 'Kelola pembayaran iuran bulanan',
            onTap: () => Get.to(() => const ManageFinanceScreen()),
          ),
        );
      }
    }

    if (hasOrg) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 32));
      }
      children.addAll([
        const Text(
          "Manajemen Organisasi",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: KTColor.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
      ]);
      if (canAccess('members')) {
        children.add(
          _buildAdminMenuTile(
            icon: Icons.people_rounded,
            title: 'Kelola Anggota',
            subtitle: 'Verifikasi dan kelola database anggota',
            onTap: () => Get.to(() => const ManageMembersScreen()),
          ),
        );
      }
      if (canAccess('polling')) {
        children.add(
          _buildAdminMenuTile(
            icon: Icons.poll_rounded,
            title: 'Kelola Polling',
            subtitle: 'Buat voting untuk pengambilan keputusan',
            onTap: () => Get.to(() => const ManagePollingScreen()),
          ),
        );
      }
      if (canAccess('pojok_kampung')) {
        children.add(
          _buildAdminMenuTile(
            icon: Icons.storefront_rounded,
            title: 'Pojok Kampung',
            subtitle: 'Kelola aspirasi dan produk warga',
            onTap: () => Get.to(() => const ManagePojokKampungScreen()),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: KTColor.textPrimary,
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: children,
      ),
    );
  }

  Widget _buildAdminMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KTColor.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: KTColor.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: KTColor.primary, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: KTColor.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: KTColor.textSecondary),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: KTColor.textSecondary.withOpacity(0.5),
        ),
      ),
    );
  }
}
