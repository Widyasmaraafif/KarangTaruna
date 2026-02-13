import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/alert_dialog.dart';
import 'package:karang_taruna/commons/widgets/containers/announcement_card.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DataController controller = Get.find<DataController>();

    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text(
          "Pengumuman",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: KTColor.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: KTColor.textPrimary,
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.announcements.isEmpty &&
            controller.isLoadingAnnouncements.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.announcements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign_outlined, size: 64, color: KTColor.border),
                const SizedBox(height: 16),
                Text(
                  "Belum ada pengumuman",
                  style: TextStyle(color: KTColor.textSecondary),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchAnnouncements(),
          color: KTColor.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.announcements.length,
            separatorBuilder: (context, index) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final item = controller.announcements[index];
              return KTAnnouncementCard(
                title: item['title'] ?? 'Tanpa Judul',
                description: item['description'] ?? '',
                badgeText: item['badge_text'] ?? 'Info',
                onTap: () {
                  // Show detail dialog
                  KTAlertDialog.show(
                    context,
                    title: item['title'] ?? 'Detail Pengumuman',
                    content: item['description'] ?? '',
                    onConfirm: () {},
                    confirmText: 'Tutup',
                    confirmColor: KTColor.primary,
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
