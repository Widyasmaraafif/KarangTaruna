import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:karang_taruna/commons/widgets/alert_dialog.dart';
import 'package:karang_taruna/commons/widgets/buttons/kt_button.dart';
import 'package:karang_taruna/commons/widgets/inputs/kt_text_field.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

class ManageAnnouncementsScreen extends StatelessWidget {
  const ManageAnnouncementsScreen({super.key});

  void _deleteAnnouncement(BuildContext context, int id) {
    final supabaseService = SupabaseService();
    final dataController = Get.find<DataController>();

    KTAlertDialog.show(
      context,
      title: 'Hapus Pengumuman',
      content: 'Apakah Anda yakin ingin menghapus pengumuman ini?',
      confirmText: 'Hapus',
      confirmColor: KTColor.error,
      onConfirm: () async {
        try {
          await supabaseService.deleteAnnouncement(id);
          await dataController.fetchAnnouncements();
          Get.snackbar(
            'Sukses',
            'Pengumuman berhasil dihapus',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: KTColor.success,
            colorText: Colors.white,
            icon: const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.white,
            ),
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Gagal menghapus pengumuman: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: KTColor.error,
            colorText: Colors.white,
            icon: const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
            ),
          );
        }
      },
    );
  }

  void _showForm({Map<String, dynamic>? item}) {
    final supabaseService = SupabaseService();
    final dataController = Get.find<DataController>();

    final titleController = TextEditingController(text: item?['title']);
    final descriptionController = TextEditingController(
      text: item?['description'],
    );
    final badgeTextController = TextEditingController(
      text: item?['badge_text'] ?? 'Info',
    );
    bool isSaving = false;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item == null ? 'Tambah Pengumuman' : 'Edit Pengumuman',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: KTColor.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  KTTextField(
                    controller: titleController,
                    labelText: 'Judul',
                    hintText: 'Masukkan judul pengumuman',
                  ),
                  const SizedBox(height: 16),
                  KTTextField(
                    controller: descriptionController,
                    labelText: 'Deskripsi',
                    hintText: 'Masukkan deskripsi pengumuman',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  KTTextField(
                    controller: badgeTextController,
                    labelText: 'Label Badge',
                    hintText: 'contoh: Info, Penting, Update',
                  ),
                  const SizedBox(height: 24),
                  KTButton(
                    text: item == null ? 'Simpan' : 'Update',
                    onPressed: () async {
                      if (titleController.text.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Judul wajib diisi',
                          backgroundColor: KTColor.warning,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      setState(() => isSaving = true);

                      try {
                        final data = {
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'badge_text': badgeTextController.text,
                          'updated_at': DateTime.now().toIso8601String(),
                        };

                        if (item == null) {
                          data['created_at'] = DateTime.now().toIso8601String();
                          await supabaseService.createAnnouncement(data);

                          Get.back();
                          Get.snackbar(
                            'Sukses',
                            'Pengumuman berhasil ditambahkan',
                            backgroundColor: KTColor.success,
                            colorText: Colors.white,
                          );
                        } else {
                          await supabaseService.updateAnnouncement(
                            item['id'],
                            data,
                          );

                          Get.back();
                          Get.snackbar(
                            'Sukses',
                            'Pengumuman berhasil diperbarui',
                            backgroundColor: KTColor.success,
                            colorText: Colors.white,
                          );
                        }

                        await dataController.fetchAnnouncements();
                      } catch (e) {
                        setState(() => isSaving = false);
                        Get.snackbar(
                          'Error',
                          'Gagal menyimpan: $e',
                          backgroundColor: KTColor.error,
                          colorText: Colors.white,
                        );
                      }
                    },
                    isLoading: isSaving,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataController>();

    return Scaffold(
      backgroundColor: KTColor.background,
      appBar: AppBar(
        title: const Text(
          'Kelola Pengumuman',
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
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchAnnouncements,
        color: KTColor.primary,
        child: Obx(() {
          if (controller.announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 64,
                    color: KTColor.border,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pengumuman',
                    style: TextStyle(
                      color: KTColor.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.announcements.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = controller.announcements[index];
              final date = DateTime.parse(item['created_at']);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: KTColor.border.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: KTColor.shadow.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: KTColor.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item['badge_text'] ?? 'Info',
                              style: const TextStyle(
                                color: KTColor.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: KTColor.textPrimary,
                              ),
                            ),
                          ),
                          PopupMenuButton(
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: KTColor.textSecondary,
                              size: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_rounded, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_rounded,
                                      size: 18,
                                      color: KTColor.error,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Hapus',
                                      style: TextStyle(color: KTColor.error),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showForm(item: item);
                              } else if (value == 'delete') {
                                _deleteAnnouncement(context, item['id']);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['description'] ?? '',
                        style: const TextStyle(
                          color: KTColor.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: KTColor.textGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm').format(date),
                            style: const TextStyle(
                              color: KTColor.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: KTColor.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
