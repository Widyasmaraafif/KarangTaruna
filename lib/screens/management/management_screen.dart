import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/controllers/data_controller.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Pengurus",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchManagement,
        child: Obx(() {
          var members = controller.management.toList();

          // Fallback data if API returns empty
          if (members.isEmpty) {
            members = [
              {
                'name': 'Budi Santoso',
                'position': 'Ketua Karang Taruna',
                'image_url':
                    'https://ui-avatars.com/api/?name=Budi+Santoso&background=0D8ABC&color=fff',
              },
              {
                'name': 'Siti Aminah',
                'position': 'Sekretaris',
                'image_url':
                    'https://ui-avatars.com/api/?name=Siti+Aminah&background=random',
              },
              {
                'name': 'Ahmad Rizki',
                'position': 'Bendahara',
                'image_url':
                    'https://ui-avatars.com/api/?name=Ahmad+Rizki&background=random',
              },
              {
                'name': 'Dewi Ratna',
                'position': 'Koordinator Acara',
                'image_url':
                    'https://ui-avatars.com/api/?name=Dewi+Ratna&background=random',
              },
              {
                'name': 'Rudi Hartono',
                'position': 'Humas',
                'image_url':
                    'https://ui-avatars.com/api/?name=Rudi+Hartono&background=random',
              },
            ];
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final member = members[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      member['image_url'] ??
                          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(member['name'] ?? 'User')}&background=random',
                    ),
                  ),
                  title: Text(
                    member['name'] ?? 'Nama Tidak Diketahui',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    member['position'] ?? 'Anggota',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BA9B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Color(0xFF00BA9B),
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
