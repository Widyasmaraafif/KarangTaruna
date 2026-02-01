import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/alert_dialog.dart';
import 'package:karang_taruna/commons/widgets/containers/announcement_card.dart';
import 'package:karang_taruna/controllers/data_controller.dart';

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DataController controller = Get.find<DataController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Semua Pengumuman"),
        backgroundColor: const Color(0xFF00BA9B),
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.announcements.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Belum ada pengumuman",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchAnnouncements(),
          color: const Color(0xFF00BA9B),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.announcements.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = controller.announcements[index];
              return KTAnnouncementCard(
                title: item['title'],
                description: item['description'] ?? '',
                badgeText: item['badge_text'] ?? 'Info',
                onTap: () {
                  // Show detail dialog
                  KTAlertDialog.show(
                    context,
                    title: item['title'],
                    content: item['description'] ?? '',
                    onConfirm: () {},
                    confirmText: 'Tutup',
                    confirmColor: const Color(0xFF00BA9B),
                    showCancel: false,
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }
}
