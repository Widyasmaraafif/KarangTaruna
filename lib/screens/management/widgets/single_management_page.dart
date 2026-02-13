import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../commons/styles/kt_color.dart';

class SingleManagementPage extends StatelessWidget {
  final Map<String, dynamic> member;

  const SingleManagementPage({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final name = member['full_name'] ?? 'Nama Tidak Diketahui';
    final role = member['role'] ?? 'Anggota';
    final avatarUrl = member['avatar_url'];

    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text(
          "Detail Pengurus",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: KTColor.textPrimary,
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Hero(
                tag: 'avatar_${member['id'] ?? name}',
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: KTColor.border.withOpacity(0.5),
                  backgroundImage: NetworkImage(
                    avatarUrl ??
                        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: KTColor.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: KTColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                role,
                style: const TextStyle(
                  fontSize: 16,
                  color: KTColor.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Information Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: KTColor.border),
                boxShadow: [
                  BoxShadow(
                    color: KTColor.shadow.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informasi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: KTColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoItem(
                    Icons.badge_outlined,
                    "ID Anggota",
                    member['id']?.toString().split('-').first ?? '-',
                  ),
                  // Add more fields if available in profiles table
                  // _buildInfoItem(Icons.email_outlined, "Email", member['email'] ?? '-'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: KTColor.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KTColor.border),
            ),
            child: Icon(icon, color: KTColor.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: KTColor.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: KTColor.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
