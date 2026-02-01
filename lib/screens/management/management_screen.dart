import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/containers/management_card.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/screens/management/widgets/single_management_page.dart';

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
              // Data comes directly from profiles table now (flat structure)
              final name = member['full_name'] ?? 'Nama Tidak Diketahui';
              final imageUrl = member['avatar_url'];
              final role = member['role'] ?? 'Anggota';

              return KTManagementCard(
                name: name,
                position: role,
                imageUrl: imageUrl,
                onTap: () => Get.to(() => SingleManagementPage(member: member)),
              );
            },
          );
        }),
      ),
    );
  }
}
