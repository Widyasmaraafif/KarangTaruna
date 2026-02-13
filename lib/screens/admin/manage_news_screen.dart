import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:karang_taruna/commons/widgets/alert_dialog.dart';
import 'package:karang_taruna/commons/widgets/buttons/kt_button.dart';
import 'package:karang_taruna/commons/widgets/inputs/kt_text_field.dart';
import 'package:karang_taruna/controllers/data_controller.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:karang_taruna/commons/styles/kt_color.dart';

class ManageNewsScreen extends StatelessWidget {
  const ManageNewsScreen({super.key});

  void _confirmDelete(int id) {
    final SupabaseService supabaseService = SupabaseService();
    final DataController dataController = Get.find<DataController>();

    KTAlertDialog.show(
      Get.context!,
      title: 'Hapus Berita',
      content: 'Apakah Anda yakin ingin menghapus berita ini?',
      confirmText: 'Hapus',
      confirmColor: KTColor.error,
      onConfirm: () async {
        try {
          await supabaseService.deleteNews(id);
          dataController.fetchNews();
          Get.snackbar(
            'Sukses',
            'Berita berhasil dihapus',
            backgroundColor: KTColor.success,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Gagal menghapus berita: $e',
            backgroundColor: KTColor.error,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  void _showNewsForm({Map<String, dynamic>? news}) {
    final controller = Get.find<DataController>();
    final supabaseService = SupabaseService();

    final titleController = TextEditingController(text: news?['title']);
    final contentController = TextEditingController(text: news?['content']);
    final authorController = TextEditingController(
      text: news?['author'] ?? controller.userProfile['full_name'] ?? 'Admin',
    );

    File? imageFile;
    String? imageUrl = news?['image_url'];
    final isSaving = false.obs;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        news == null ? 'Tambah Berita' : 'Edit Berita',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: KTColor.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: KTColor.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1024,
                        maxHeight: 1024,
                        imageQuality: 85,
                      );
                      if (pickedFile != null) {
                        setState(() {
                          imageFile = File(pickedFile.path);
                        });
                      }
                    },
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: KTColor.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: KTColor.border.withValues(alpha: 0.5),
                        ),
                        image: imageFile != null
                            ? DecorationImage(
                                image: FileImage(imageFile!),
                                fit: BoxFit.cover,
                              )
                            : (imageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(imageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                      ),
                      child: imageFile == null && imageUrl == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 40,
                                  color: KTColor.textSecondary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pilih Foto Berita',
                                  style: TextStyle(
                                    color: KTColor.textSecondary.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  KTTextField(
                    controller: titleController,
                    labelText: 'Judul Berita',
                    hintText: 'Masukkan judul berita',
                  ),
                  const SizedBox(height: 16),
                  KTTextField(
                    controller: contentController,
                    labelText: 'Konten',
                    hintText: 'Masukkan isi berita',
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  KTTextField(
                    controller: authorController,
                    labelText: 'Penulis',
                    hintText: 'Nama penulis',
                  ),
                  const SizedBox(height: 32),
                  Obx(
                    () => KTButton(
                      text: news == null ? 'Publikasikan' : 'Simpan Perubahan',
                      isLoading: isSaving.value,
                      onPressed: () async {
                        if (titleController.text.isEmpty ||
                            contentController.text.isEmpty) {
                          Get.snackbar(
                            'Peringatan',
                            'Judul dan konten wajib diisi',
                            backgroundColor: KTColor.warning,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        isSaving.value = true;

                        try {
                          if (imageFile != null) {
                            imageUrl = await supabaseService.uploadNewsImage(
                              imageFile!,
                            );
                          }

                          final data = {
                            'title': titleController.text,
                            'content': contentController.text,
                            'author': authorController.text,
                            'image_url': imageUrl,
                            'update_at': DateTime.now().toIso8601String(),
                          };

                          if (news == null) {
                            data['created_at'] = DateTime.now()
                                .toIso8601String();
                            await supabaseService.createNews(data);
                            Get.back();
                            Get.snackbar(
                              'Sukses',
                              'Berita berhasil ditambahkan',
                              backgroundColor: KTColor.success,
                              colorText: Colors.white,
                            );
                          } else {
                            await supabaseService.updateNews(news['id'], data);
                            Get.back();
                            Get.snackbar(
                              'Sukses',
                              'Berita berhasil diperbarui',
                              backgroundColor: KTColor.success,
                              colorText: Colors.white,
                            );
                          }

                          controller.fetchNews();
                        } catch (e) {
                          isSaving.value = false;
                          Get.snackbar(
                            'Error',
                            'Gagal menyimpan berita: $e',
                            backgroundColor: KTColor.error,
                            colorText: Colors.white,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
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
        title: const Text('Kelola Berita'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: KTColor.textPrimary,
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchNews,
        color: KTColor.primary,
        child: Obx(() {
          if (controller.isLoadingNews.value && controller.news.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: KTColor.primary),
            );
          }

          if (controller.news.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined, size: 64, color: KTColor.border),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada berita',
                    style: TextStyle(
                      color: KTColor.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.news.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final news = controller.news[index];
              final date =
                  DateTime.tryParse(news['created_at'] ?? '') ?? DateTime.now();

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: KTColor.border.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: KTColor.shadow.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (news['image_url'] != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          news['image_url'],
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 160,
                                color: KTColor.background,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: KTColor.border,
                                ),
                              ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  news['title'] ?? 'Tanpa Judul',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: KTColor.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                                        Icon(
                                          Icons.edit_rounded,
                                          size: 18,
                                          color: KTColor.textPrimary,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: KTColor.textPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
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
                                          style: TextStyle(
                                            color: KTColor.error,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showNewsForm(news: news);
                                  } else if (value == 'delete') {
                                    _confirmDelete(news['id']);
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: KTColor.background,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person_rounded,
                                      size: 12,
                                      color: KTColor.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      news['author'] ?? 'Admin',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: KTColor.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 12,
                                    color: KTColor.textSecondary.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('dd MMM yyyy').format(date),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: KTColor.textSecondary.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewsForm(),
        backgroundColor: KTColor.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
