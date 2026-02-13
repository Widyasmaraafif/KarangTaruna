import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/containers/management_card.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/screens/management/widgets/single_management_page.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();

    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text('Manajemen Pengurus'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: KTColor.textPrimary,
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchManagement,
        color: KTColor.primary,
        child: Obx(() {
          var members = controller.management.toList();

          if (members.isEmpty && controller.isLoadingManagement.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (members.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 64,
                    color: KTColor.border,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data pengurus',
                    style: TextStyle(color: KTColor.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: members.length,
            separatorBuilder: (context, index) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final member = members[index];
              final name = member['full_name'] ?? 'Nama Tidak Diketahui';
              final imageUrl = member['avatar_url'];
              final role = member['role'] ?? 'Anggota';

              return KTManagementCard(
                name: name,
                position: role,
                imageUrl: imageUrl,
                onTap: () => Get.to(
                  () => SingleManagementPage(member: member),
                  transition: Transition.cupertino,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
